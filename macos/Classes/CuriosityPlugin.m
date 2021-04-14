#import "CuriosityPlugin.h"
#import "ScannerTools.h"
#import "NativeTools.h"
#import <Cocoa/Cocoa.h>

@implementation CuriosityPlugin{
    NSObject<FlutterTextureRegistry> *registry;
    FlutterEventChannel *eventChannel;
    FlutterMethodCall *call;
    FlutterResult result;
    NSWindow *mainWindow;
}
NSString * const curiosity=@"Curiosity";

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
    mainWindow= [[NSApplication sharedApplication] mainWindow];
    return self;
}
- (void)handleMethodCall:(FlutterMethodCall*)_call result:(FlutterResult)_result {
    call = _call;
    result = _result;
    if ([@"getGPSStatus" isEqualToString:call.method]) {
        result([NSNumber numberWithBool:[NativeTools getGPSStatus]?YES:NO]);
    }else if ([@"jumpAppSetting" isEqualToString:call.method]) {
        result([NSNumber numberWithBool:[NativeTools getGPSStatus]?YES:NO]);
    }else if ([@"getAppInfo" isEqualToString:call.method]) {
        result([NativeTools getAppInfo]);
    }else if ([@"scanImagePath" isEqualToString:call.method]) {
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
        //  [NativeTools systemShare:call result:result];
    }else if ([@"getWindowSize" isEqualToString:call.method]) {
        CGFloat width = mainWindow.frame.size.width;
        CGFloat height = mainWindow.frame.size.height;
        result(@[[NSNumber numberWithDouble:width],[NSNumber numberWithDouble:height]]);
    } else if ([@"setWindowSize" isEqualToString:call.method]) {
        NSNumber *width = ((NSNumber *)call.arguments[@"width"]);
        NSNumber *height = ((NSNumber *)call.arguments[@"height"]);
        
        NSRect rect= mainWindow.frame;
        rect.origin.y += (rect.size.height - [height doubleValue]);
        rect.size.width = [width doubleValue];
        rect.size.height = [height doubleValue];
        [mainWindow setFrame:rect display:true animate:true];
        
    } else if ([@"setMinWindowSize" isEqualToString:call.method]) {
        NSNumber *width = ((NSNumber *)call.arguments[@"width"]);
        NSNumber *height = ((NSNumber *)call.arguments[@"height"]);
        mainWindow.minSize = CGSizeMake([width doubleValue], [height doubleValue]);
    } else if ([@"setMaxWindowSize" isEqualToString:call.method]) {
        NSNumber *width = ((NSNumber *)call.arguments[@"width"]);
        NSNumber *height = ((NSNumber *)call.arguments[@"height"]);
        if (width == 0 || height == 0) {
            mainWindow.minSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        } else {
            mainWindow.maxSize = CGSizeMake([width doubleValue],[height doubleValue]);
        }
    } else if ([@"resetMaxWindowSize" isEqualToString:call.method]) {
        mainWindow.minSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        result([NSNumber numberWithBool:YES]);
    } else if ([@"toggleFullScreen" isEqualToString:call.method]) {
        [mainWindow toggleFullScreen:nil];
        result([NSNumber numberWithBool:YES]);
    } else if ([@"setFullScreen" isEqualToString:call.method]) {
        BOOL fullscreen = [call.arguments[@"fullscreen"] boolValue];
        if((mainWindow.styleMask == NSFullScreenWindowMask)!=fullscreen){
            [mainWindow toggleFullScreen:nil];
        }
    } else if ([@"getFullScreen" isEqualToString:call.method]) {
        
        result([NSNumber numberWithBool:mainWindow.styleMask == NSFullScreenWindowMask]);
        
    } else if ([@"exitApp" isEqualToString:call.method]) {
        exit(0);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
