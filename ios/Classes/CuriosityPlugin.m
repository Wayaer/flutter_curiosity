#import "CuriosityPlugin.h"
#import "ScannerTools.h"
#import "ScannerFactory.h"
#import "NativeTools.h"
#import "FileTools.h"
#import "PicturePicker.h"
#import "ScannerView.h"

@implementation CuriosityPlugin{
    UIViewController *viewController;
    NSObject<FlutterPluginRegistrar>*registrar;
    FlutterMethodCall *call;
    FlutterResult result;
    FlutterEventChannel *eventChannel;
    FlutterEventSink eventSink;
    ScannerView *scannerView;
    int64_t scannerViewId;
}
NSString * const curiosity=@"Curiosity";

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:curiosity
                                     binaryMessenger:[registrar messenger]];
    UIViewController *viewController =
    [UIApplication sharedApplication].delegate.window.rootViewController;
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"Curiosity/event" binaryMessenger:[registrar messenger]];
    CuriosityPlugin* plugin = [[CuriosityPlugin alloc] initWithCuriosityPlugin:viewController :registrar :eventChannel];
    [registrar addMethodCallDelegate:plugin channel:channel];
}
- (instancetype)initWithCuriosityPlugin:(UIViewController *)_viewController :(NSObject<FlutterPluginRegistrar>*)_registrar
                                       :( FlutterEventChannel *)_eventChannel {
    self = [super init];
    if (self){
        viewController = _viewController;
        registrar = _registrar;
        [_eventChannel setStreamHandler:self];
        
    }
    return self;
}
- (void)handleMethodCall:(FlutterMethodCall*)_call result:(FlutterResult)_result {
    call = _call;
    result = _result;
    [self gallery];
    [self scanner];
    [self tools];
}

-(void)gallery{
    if ([@"openPicker" isEqualToString:call.method]) {
        [PicturePicker openPicker:call viewController:viewController result:result];
    }
    if ([@"openCamera" isEqualToString:call.method]) {
        [PicturePicker openCamera:viewController result:result];
    }
    if ([@"deleteCacheDirFile" isEqualToString:call.method]) {
        [PicturePicker deleteCacheDirFile];
    }
}
-(void)scanner{
    if ([@"scanImagePath" isEqualToString:call.method]) {
        [ScannerTools scanImagePath:call result:result];
    }
    if ([@"scanImageUrl" isEqualToString:call.method]) {
        [ScannerTools scanImageUrl:call result:result];
    }
    if ([@"scanImageMemory" isEqualToString:call.method]) {
        [ScannerTools scanImageMemory:call result:result];
    }
    if ([@"availableCameras" isEqualToString:call.method]) {
        [ScannerTools availableCameras:call result:result];
    }
    if([@"initializeCameras" isEqualToString:call.method]){
        [NativeTools log:@"开始初始化相机"];
        NSString *cameraId = call.arguments[@"cameraId"];
        NSString *resolutionPreset = call.arguments[@"resolutionPreset"];
        NSError * error;
        [NativeTools log:cameraId];
        scannerView = [[ScannerView alloc] initWitchCamera:cameraId :resolutionPreset :&error];
        if(error){
            result(getFlutterError(error));
            return;
        }else{
            if(scannerView)[scannerView close];
            scannerViewId = [[registrar textures] registerTexture:scannerView];
            scannerView.eventSink = eventSink;
            result(@{
                @"textureId":@(scannerViewId),
                @"previewWidth":@(scannerView.previewSize.width),
                @"previewHeight":@(scannerView.previewSize.height)
                   });
            [scannerView start];
        }
    }
    if([@"disposeCameras" isEqualToString:call.method]){
        if(scannerView)[scannerView close];
        if(scannerViewId) [[registrar textures] unregisterTexture:scannerViewId];
    }
    if ([call.method isEqualToString:@"setFlashMode"]){
        NSNumber * status = [call.arguments valueForKey:@"status"];
       if(scannerView)[scannerView setFlashMode:[status boolValue]];
    }
    
}

-(void)tools{
    if ([@"getGPSStatus" isEqualToString:call.method]) {
        [NativeTools getGPSStatus];
    }
    if ([@"jumpGPSSetting" isEqualToString:call.method]) {
        [NativeTools jumpGPSSetting];
    }
    if ([@"getAppInfo" isEqualToString:call.method]) {
        result([NativeTools getAppInfo]);
    }
    if ([@"getFilePathSize" isEqualToString:call.method]) {
        result([FileTools getFilePathSize:call.arguments[@"filePath"]]);
    }
    if ([@"unZipFile" isEqualToString:call.method]) {
        [FileTools unZipFile:call.arguments[@"filePath"]];
        result( @"success");
    }
    if ([@"goToMarket" isEqualToString:call.method]) {
        [NativeTools goToMarket:call.arguments[@"packageName"]];
        result( @"success");
    }
    if ([@"callPhone" isEqualToString:call.method]) {
        [NativeTools callPhone:call.arguments[@"phoneNumber"] :call.arguments[@"directDial"]];
        result( @"success");
    }
    if ([@"systemShare" isEqualToString:call.method]) {
        [NativeTools systemShare:call result:result];
    }
    if ([@"exitApp" isEqualToString:call.method]) {
        exit(0);
    }
}
- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    eventSink = nil;
    [eventChannel setStreamHandler:nil];
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(FlutterEventSink)_eventSink {
    eventSink = _eventSink;
    return nil;
}
static FlutterError *getFlutterError(NSError *error) {
    return [FlutterError errorWithCode:[NSString stringWithFormat:@"%d", (int)error.code]
                               message:error.localizedDescription
                               details:error.domain];
}
@end
