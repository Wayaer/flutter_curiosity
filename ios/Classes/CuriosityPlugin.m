#import "CuriosityPlugin.h"
#import "ScannerTools.h"
#import "NativeTools.h"
#import "FileTools.h"
#import "PicturePicker.h"
#import "ScannerView.h"

API_AVAILABLE(ios(10.0))

@implementation CuriosityPlugin{
    UIViewController *viewController;
    NSObject<FlutterTextureRegistry> *registry;
    FlutterEventChannel *eventChannel;
    FlutterMethodCall *call;
    FlutterResult result;
    ScannerView *scannerView;
}
NSString * const curiosity=@"Curiosity";
NSString * const curiosityEvent=@"Curiosity/event";

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:curiosity
                                     binaryMessenger:[registrar messenger]];
    UIViewController *viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    CuriosityPlugin* plugin = [[CuriosityPlugin alloc] initWithCuriosity:viewController registrar:registrar];
    [registrar addMethodCallDelegate:plugin channel:channel];
}
- (instancetype)initWithCuriosity:(UIViewController *)_viewController
                        registrar:(NSObject<FlutterPluginRegistrar>*)_registrar {
    self = [super init];
    viewController = _viewController;
    registry =[_registrar textures];
    eventChannel = [FlutterEventChannel eventChannelWithName:curiosityEvent binaryMessenger:[_registrar messenger]];
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
        NSString *cameraId = call.arguments[@"cameraId"];
        NSString *resolutionPreset = call.arguments[@"resolutionPreset"];
        NSError * error;
        if (@available(iOS 10.0, *)) {
            ScannerView *view = [[ScannerView alloc] initWitchCamera:cameraId :resolutionPreset :&error];
            if(error){
                result(getFlutterError(error));
                return;
            }else{
                if(scannerView)[scannerView close];
                int64_t scannerViewId = [registry registerTexture:view];
                scannerView = view;
                [eventChannel setStreamHandler:view];
                view.eventChannel = eventChannel;
                view.onFrameAvailable = ^{
                    [self->registry textureFrameAvailable:scannerViewId];
                };
                result(@{
                    @"textureId":@(scannerViewId),
                    @"previewWidth":@(view.previewSize.width),
                    @"previewHeight":@(view.previewSize.height)
                       });
                [view start];
            }
        }else{
            result(@"Not supported below ios10");
        }
    }
    if([@"disposeCameras" isEqualToString:call.method]){
        NSDictionary *arguments = call.arguments;
        NSUInteger textureId = ((NSNumber *)arguments[@"textureId"]).unsignedIntegerValue;
        if(scannerView)[scannerView close];
        if(textureId) [registry unregisterTexture:textureId];
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

static FlutterError *getFlutterError(NSError *error) {
    return [FlutterError errorWithCode:[NSString stringWithFormat:@"%d", (int)error.code]
                               message:error.localizedDescription
                               details:error.domain];
}
@end
