#import "CuriosityPlugin.h"
#import "ScannerTools.h"
#import "NativeTools.h"
#import <Photos/Photos.h>


@implementation CuriosityPlugin{
    NSObject<FlutterTextureRegistry> *registry;
    FlutterEventChannel *eventChannel;
    FlutterMethodCall *call;
    FlutterResult result;
}
NSString * const curiosity=@"Curiosity";
NSString * const curiosityEvent=@"Curiosity/event";

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:curiosity
                                     binaryMessenger:[registrar messenger]];
    //    NSViewController *viewController = [NSViewController sharedApplication].delegate.window.rootViewController;
    CuriosityPlugin* plugin = [[CuriosityPlugin alloc] initWithCuriosity:registrar];
    [registrar addMethodCallDelegate:plugin channel:channel];
}
- (instancetype)initWithCuriosity:(NSObject<FlutterPluginRegistrar>*)_registrar{
    self = [super init];
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
        if ([@"openImagePicker" isEqualToString:call.method]) {
//            [NativeTools openImagePicker:call :viewController :result];
        }
    //    if ([@"deleteCacheDirFile" isEqualToString:call.method]) {
    //        [GalleryTools deleteCacheDirFile:result];
    //    }
    //    if ([@"openSystemGallery" isEqualToString:call.method]) {
    //        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    //        picker.delegate = self;
    //        [GalleryTools openSystemGallery:viewController :picker :result];
    //    }
    //    if ([@"openSystemCamera" isEqualToString:call.method]) {
    //        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    //        picker.delegate = self;
    //        [GalleryTools openSystemCamera:viewController :picker :result];
    //    }
    //    if ([@"saveImageToGallery" isEqualToString:call.method]) {
    //        [self saveImageToGallery];
    //    }
    //    if ([@"saveFileToGallery" isEqualToString:call.method]) {
    //        [self saveFileToGallery];
    //    }
}
-(void)scanner{
    //    if ([@"scanImagePath" isEqualToString:call.method]) {
    //        [ScannerTools scanImagePath:call result:result];
    //    }
    //    if ([@"scanImageUrl" isEqualToString:call.method]) {
    //        [ScannerTools scanImageUrl:call result:result];
    //    }
    //    if ([@"scanImageMemory" isEqualToString:call.method]) {
    //        [ScannerTools scanImageMemory:call result:result];
    //    }
    //    if ([@"availableCameras" isEqualToString:call.method]) {
    //        [ScannerTools availableCameras:call result:result];
    //    }
    //    if([@"initializeCameras" isEqualToString:call.method]){
    //        NSString *cameraId = call.arguments[@"cameraId"];
    //        NSString *resolutionPreset = call.arguments[@"resolutionPreset"];
    //        NSError * error;
    //        if (@available(iOS 10.0, *)) {
    //            ScannerView *view = [[ScannerView alloc] initWitchCamera:cameraId :resolutionPreset :&error];
    //            if(error){
    //                result(getFlutterError(error));
    //                return;
    //            }else{
    //                if(scannerView)[scannerView close];
    //                int64_t scannerViewId = [registry registerTexture:view];
    //                scannerView = view;
    //                [eventChannel setStreamHandler:view];
    //                view.eventChannel = eventChannel;
    //                view.onFrameAvailable = ^{
    //                    [self->registry textureFrameAvailable:scannerViewId];
    //                };
    //                result(@{
    //                    @"textureId":@(scannerViewId),
    //                    @"previewWidth":@(view.previewSize.width),
    //                    @"previewHeight":@(view.previewSize.height)
    //                       });
    //                [view start];
    //            }
    //        }else{
    //            result([Tools resultInfo:@"Not supported below ios10"]);
    //        }
    //    }
    //    if([@"disposeCameras" isEqualToString:call.method]){
    //        NSDictionary *arguments = call.arguments;
    //        NSUInteger textureId = ((NSNumber *)arguments[@"textureId"]).unsignedIntegerValue;
    //        if(scannerView)[scannerView close];
    //        if(textureId) [registry unregisterTexture:textureId];
    //        result([Tools resultInfo:@"dispose"]);
    //    }
    //    if ([call.method isEqualToString:@"setFlashMode"]){
    //        NSNumber * status = [call.arguments valueForKey:@"status"];
    //        if(scannerView)[scannerView setFlashMode:[status boolValue]];
    //        result([Tools resultInfo:@"setFlashMode"]);
    //    }
    //
}

-(void)tools{
    if ([@"getGPSStatus" isEqualToString:call.method]) {
        result([NSNumber numberWithBool:[NativeTools getGPSStatus]?YES:NO]);
    }
    if ([@"jumpAppSetting" isEqualToString:call.method]) {
        result([NSNumber numberWithBool:[NativeTools getGPSStatus]?YES:NO]);
    }
    if ([@"getAppInfo" isEqualToString:call.method]) {
        result([NativeTools getAppInfo]);
    }
    if ([@"getFilePathSize" isEqualToString:call.method]) {
        result([NativeTools getFilePathSize:call.arguments[@"filePath"]]);
    }
    if ([@"unZipFile" isEqualToString:call.method]) {
//        [NativeTools unZipFile:call.arguments[@"filePath"]];
        result([Tools resultSuccess]);
    }
    if ([@"goToMarket" isEqualToString:call.method]) {
        [NativeTools goToMarket:call.arguments[@"packageName"]];
        result([Tools resultSuccess]);
    }
    if ([@"callPhone" isEqualToString:call.method]) {
        //        [NativeTools callPhone:call.arguments[@"phoneNumber"]];
        result([Tools resultSuccess]);
    }
    if ([@"systemShare" isEqualToString:call.method]) {
        //        [NativeTools systemShare:call result:result];
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
