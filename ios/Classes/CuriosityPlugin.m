#import "CuriosityPlugin.h"
#import "ScanUtils.h"
#import "ScanViewFactory.h"
#import "NativeUtils.h"
#import "FileUtils.h"
#import "PicturePicker.h"
#import "AppInfo.h"

@implementation CuriosityPlugin{
    UIViewController *viewController;
    FlutterMethodCall *call;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"Curiosity"
                                     binaryMessenger:[registrar messenger]];
    UIViewController *viewController =
    [UIApplication sharedApplication].delegate.window.rootViewController;
    CuriosityPlugin* instance = [[CuriosityPlugin alloc] initWithViewController:viewController];
    [registrar addMethodCallDelegate:instance channel:channel];
      ScanViewFactory * scanView=[[ScanViewFactory alloc]initWithMessenger:[registrar messenger]];
    
      [registrar registerViewFactory:scanView withId:@"scanView"];
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
    [self scan:result];
    [self getAppInfo:result];
    [self utils:result];
    
}

-(void)gallery:(FlutterResult)result{
    if ([@"openPicker" isEqualToString:call.method]) {
       [PicturePicker openPicker:call.arguments viewController:viewController result:result];
    } else if ([@"openCamera" isEqualToString:call.method]) {
    [PicturePicker openCamera:call.arguments viewController:viewController result:result];
    } else if ([@"deleteCacheDirFile" isEqualToString:call.method]) {
        [PicturePicker deleteCacheDirFile];
    }
}
-(void)scan:(FlutterResult)result{
    if ([@"scanImagePath" isEqualToString:call.method]) {
          [ScanUtils scanImagePath:call result:result];
      }else if ([@"scanImageUrl" isEqualToString:call.method]) {
          [ScanUtils scanImageUrl:call result:result];
      }if ([@"scanImageMemory" isEqualToString:call.method]) {
          [ScanUtils scanImageMemory:call result:result];
      }
}
-(void)getAppInfo:(FlutterResult)result{
    if ([@"getAppInfo" isEqualToString:call.method]) {
        result([AppInfo getAppInfo]);
    }else if([@"getDirectoryAllName" isEqualToString:call.method]){
        result([FileUtils getDirectoryAllName:call.arguments]);
    }
}
-(void)utils:(FlutterResult)result{
    if ([@"clearAllCookie" isEqualToString:call.method]) {
        [NativeUtils clearAllCookie];
        result( @"success");
    } else if ([@"getAllCookie" isEqualToString:call.method]) {
        result([NativeUtils getAllCookie]);
    } else if ([@"getFilePathSize" isEqualToString:call.method]) {
        result([FileUtils getFilePathSize:call.arguments[@"filePath"]]);
    } else if ([@"deleteDirectory" isEqualToString:call.method]) {
        [FileUtils deleteDirectory:call.arguments[@"directoryPath"]];
        result( @"success");
    } else if ([@"deleteFile" isEqualToString:call.method]) {
        [FileUtils deleteFile:call.arguments[@"filePath"]];
        result( @"success");
    } else if ([@"unZipFile" isEqualToString:call.method]) {
        [FileUtils unZipFile:call.arguments[@"filePath"]];
        result( @"success");
    }else if ([@"goToMarket" isEqualToString:call.method]) {
        [NativeUtils goToMarket:call.arguments[@"packageName"]];
        result( @"success");
    } else if ([@"exitApp" isEqualToString:call.method]) {
        exit(0);
    }
}

@end
