#import "CuriosityPlugin.h"
#import "ScannerTools.h"
#import "NativeTools.h"
#import "Connectivity.h"
#import "Reachability/Reachability.h"
#import <CoreWLAN/CoreWLAN.h>

@implementation CuriosityPlugin{
    NSObject<FlutterTextureRegistry> *registry;
    FlutterEventChannel *eventChannel;
    FlutterMethodCall *call;
    FlutterResult result;
    
}
NSString * const curiosity=@"Curiosity";
NSString * const connectivityEvent=@"Curiosity/event/connectivity";

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
    eventChannel = [FlutterEventChannel eventChannelWithName:connectivityEvent binaryMessenger:[_registrar messenger]];
    [eventChannel setStreamHandler:[[Connectivity alloc] init]];
    return self;
}
- (void)handleMethodCall:(FlutterMethodCall*)_call result:(FlutterResult)_result {
    call = _call;
    result = _result;
//    CWWiFiClient* cwinterface= [CWWiFiClient sharedWiFiClient].interface;
    
    if ([@"getGPSStatus" isEqualToString:call.method]) {
        result([NSNumber numberWithBool:[NativeTools getGPSStatus]?YES:NO]);
    }else if ([@"jumpAppSetting" isEqualToString:call.method]) {
        result([NSNumber numberWithBool:[NativeTools getGPSStatus]?YES:NO]);
    }else if ([@"getAppInfo" isEqualToString:call.method]) {
        result([NativeTools getAppInfo]);
    }else  if ([@"scanImagePath" isEqualToString:call.method]) {
        [ScannerTools scanImagePath:call result:result];
    }else if ([@"scanImageUrl" isEqualToString:call.method]) {
        [ScannerTools scanImageUrl:call result:result];
    }else if ([@"scanImageMemory" isEqualToString:call.method]) {
        [ScannerTools scanImageMemory:call result:result];
    }else if ([@"availableCameras" isEqualToString:call.method]) {
        [ScannerTools availableCameras:call result:result];
    }else if ([@"getFilePathSize" isEqualToString:call.method]) {
        if (@available(macOS 10.8, *)) {
            result([NativeTools getFilePathSize:call.arguments[@"filePath"]]);
        }
    }else if ([@"goToMarket" isEqualToString:call.method]) {
        [NativeTools goToMarket:call.arguments[@"packageName"]];
        result([Tools resultSuccess]);
    }else if ([@"systemShare" isEqualToString:call.method]) {
        //        [NativeTools systemShare:call result:result];
    }else if ([@"exitApp" isEqualToString:call.method]) {
        exit(0);
    }else if ([call.method isEqualToString:@"checkNetwork"]) {
        result([Tools getNetworkStatus:[Reachability reachabilityForInternetConnection]]);
    }else if ([call.method isEqualToString:@"wifiName"]) {
  
    } else if ([call.method isEqualToString:@"wifiBSSID"]) {
     
    } else if ([call.method isEqualToString:@"wifiIPAddress"]) {
   
    } else  {
        result(FlutterMethodNotImplemented);
    }
}

@end
