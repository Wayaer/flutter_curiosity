#import "NativeTools.h"
#import <CoreLocation/CoreLocation.h>
#define fileManager [NSFileManager defaultManager]

@implementation NativeTools

+ (NSDictionary *)getAppInfo{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    NSDictionary *app = [[NSBundle mainBundle] infoDictionary];
    return(@{
        @"homeDirectory" : NSHomeDirectory(),
        @"documentDirectory" : [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject],
        @"libraryDirectory" :[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject],
        @"cachesDirectory" : [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject],
        @"temporaryDirectory" :NSTemporaryDirectory(),
        @"versionName" : [app objectForKey:@"CFBundleShortVersionString"],
        @"versionCode" : [NSNumber numberWithInt:[[app objectForKey:@"CFBundleVersion"] intValue]],
        @"packageName" : [app objectForKey:@"CFBundleIdentifier"],
        @"appName" : [app objectForKey:@"CFBundleName"],
        @"sdkBuild" : [app objectForKey:@"DTSDKBuild"],
        @"platformVersion" : [app objectForKey:@"DTPlatformVersion"],
           });
    return info;
}


//判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
+ (BOOL) getGPSStatus {
    if (@available(macOS 10.7, *)) {
        return [CLLocationManager locationServicesEnabled];
    }
    return  NO;
}

//能否打开url
+ (BOOL) canOpenUrl:(NSString *)url {
    NSURL *nsUrl = [[NSURL alloc] initWithString:url];
    return [[NSWorkspace sharedWorkspace] URLForApplicationToOpenURL:nsUrl] != nil;
}
//打开url
+ (void) openUrl:(NSDictionary *)arguments {
    NSURL *nsUrl = [[NSURL alloc] initWithString:arguments[@"url"]];
    [[NSWorkspace sharedWorkspace] openURL:nsUrl];
}




@end
