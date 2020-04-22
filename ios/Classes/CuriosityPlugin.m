#import "CuriosityPlugin.h"
#import "ScannerTools.h"
#import "ScannerFactory.h"
#import "NativeTools.h"
#import "FileTools.h"
#import "PicturePicker.h"
#import "GPSTools.h"

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
    ScannerFactory * scanner=[[ScannerFactory alloc]initWithMessenger:[registrar messenger]];
    [registrar registerViewFactory:scanner withId:@"scanner"];
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
    [self scanner:result];
    [self tools:result];
    [self gps:result];
    
}

-(void)gps:(FlutterResult)result{
    if ([@"getStatus" isEqualToString:call.method]) {
        [GPSTools getStatus ];
    } else if ([@"jumpSetting" isEqualToString:call.method]) {
        [GPSTools jumpSetting];
    }
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
-(void)scanner:(FlutterResult)result{
    if ([@"scanImagePath" isEqualToString:call.method]) {
        [ScannerTools scanImagePath:call result:result];
    }else if ([@"scanImageUrl" isEqualToString:call.method]) {
        [ScannerTools scanImageUrl:call result:result];
    }if ([@"scanImageMemory" isEqualToString:call.method]) {
        [ScannerTools scanImageMemory:call result:result];
    }
}

-(void)tools:(FlutterResult)result{
    if ([@"getAppInfo" isEqualToString:call.method]) {
        result([NativeTools getAppInfo]);
    }else if([@"getDirectoryAllName" isEqualToString:call.method]){
        result([FileTools getDirectoryAllName:call.arguments]);
    }else if ([@"getFilePathSize" isEqualToString:call.method]) {
        result([FileTools getFilePathSize:call.arguments[@"filePath"]]);
    } else if ([@"deleteDirectory" isEqualToString:call.method]) {
        [FileTools deleteDirectory:call.arguments[@"directoryPath"]];
        result( @"success");
    } else if ([@"deleteFile" isEqualToString:call.method]) {
        [FileTools deleteFile:call.arguments[@"filePath"]];
        result( @"success");
    } else if ([@"unZipFile" isEqualToString:call.method]) {
        [FileTools unZipFile:call.arguments[@"filePath"]];
        result( @"success");
    }else if ([@"goToMarket" isEqualToString:call.method]) {
        [NativeTools goToMarket:call.arguments[@"packageName"]];
        result( @"success");
    } else if ([@"callPhone" isEqualToString:call.method]) {
        [NativeTools callPhone:call.arguments[@"phoneNumber"] :call.arguments[@"directDial"]];
        result( @"success");
    } else if ([@"exitApp" isEqualToString:call.method]) {
        exit(0);
    }
}

@end
