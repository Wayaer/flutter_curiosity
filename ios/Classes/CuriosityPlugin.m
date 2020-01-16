#import "CuriosityPlugin.h"

@implementation CuriosityPlugin{
    UIViewController *viewController;
    FlutterMethodCall *call;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"Curiosity"
                                     binaryMessenger:[registrar messenger]];
//    CuriosityPlugin* instance = [[CuriosityPlugin alloc] init];
//    [registrar addMethodCallDelegate:instance channel:channel];
//
    UIViewController *viewController =
        [UIApplication sharedApplication].delegate.window.rootViewController;
    CuriosityPlugin* instance = [[CuriosityPlugin alloc] initWithViewController:viewController];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithViewController:(UIViewController *)_viewController {
    self = [super init];
    if (self) {
        viewController = _viewController;
    }
    return self;
}
- (void)handleMethodCall:(FlutterMethodCall*)_call result:(FlutterResult)result {
    call=_call;
    [self gallery:result];
    [self scanQR:result];
    [self getAppInfo:result];
    [self utils:result];
    
}

-(void)gallery:(FlutterResult)result{
    if ([@"openSelect" isEqualToString:call.method]) {
        [PicturePicker openSelect:call.arguments viewController:viewController];
        result( @"openSelect");
    } else if ([@"openCamera" isEqualToString:call.method]) {
        [PicturePicker openCamera:call.arguments];
        result( @"openCamera");
    } else if ([@"deleteCacheDirFile" isEqualToString:call.method]) {
        [PicturePicker deleteCacheDirFile];
    }
}
-(void)scanQR:(FlutterResult)result{
    if ([@"scanImagePath" isEqualToString:call.method]) {
        [PicturePicker openSelect:call.arguments viewController:viewController];
        result( @"success");
    } else if ([@"scanImageUrl" isEqualToString:call.method]) {
        [PicturePicker openCamera:call.arguments];
        result( @"success");
    } else if ([@"scanImageMemory" isEqualToString:call.method]) {
        [PicturePicker deleteCacheDirFile];
    }
}
-(void)getAppInfo:(FlutterResult)result{
    if ([@"getAppInfo" isEqualToString:call.method]) {
        result([AppInfo getAppInfo]);
    }
}
-(void)utils:(FlutterResult)result{
    if ([@"clearAllCookie" isEqualToString:call.method]) {
        [NativeUtils clearAllCookie];
        result( @"success");
    } else if ([@"getAllCookie" isEqualToString:call.method]) {
        result([NativeUtils getAllCookie]);
    } else if ([@"getFilePathSize" isEqualToString:call.method]) {
        result([NativeUtils getFilePathSize:call.arguments[@"filePath"]]);
    } else if ([@"deleteFolder" isEqualToString:call.method]) {
        [NativeUtils deleteFolder:call.arguments[@"folderPath"]];
        result( @"success");
    } else if ([@"deleteFile" isEqualToString:call.method]) {
        [NativeUtils deleteFile:call.arguments[@"filePath"]];
        result( @"success");
    } else if ([@"goToMarket" isEqualToString:call.method]) {
        [NativeUtils goToMarket:call.arguments[@"packageName"]];
        result( @"success");
    } else if ([@"exitApp" isEqualToString:call.method]) {
        exit(0);
    }
}

@end
