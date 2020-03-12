#import "AppInfo.h"

@implementation AppInfo
//获取app信息
+ (NSMutableDictionary *)getAppInfo;
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    NSDictionary *app = [[NSBundle mainBundle] infoDictionary];
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    [info setObject:@(statusBar.size.height) forKey:@"statusBarHeight"];
    [info setObject:@(statusBar.size.width) forKey:@"statusBarWidth"];
    
    [info setObject:NSHomeDirectory() forKey:@"homeDirectory"];
    [info setObject:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] forKey:@"documentDirectory"];
    [info setObject:[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] forKey:@"libraryDirectory"];
    [info setObject:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] forKey:@"cachesDirectory"];
    [info setObject:NSTemporaryDirectory() forKey:@"temporaryDirectory"];
    
    [info setObject:[app objectForKey:@"CFBundleShortVersionString"] forKey:@"versionName"];
    [info setObject:@"Apple" forKey:@"phoneBrand"];
    [info setObject:[NSNumber numberWithInt:[[app objectForKey:@"CFBundleVersion"] intValue]] forKey:@"versionCode"];
    
    [info setObject:[app objectForKey:@"CFBundleIdentifier"] forKey:@"packageName"];
    [info setObject:[app objectForKey:@"CFBundleName"] forKey:@"appName"];
    [info setObject:[app objectForKey:@"DTSDKBuild"] forKey:@"sdkBuild"];
    [info setObject:[app objectForKey:@"DTPlatformName"] forKey:@"platformName"];
    [info setObject:[app objectForKey:@"MinimumOSVersion"] forKey:@"pinimumOSVersion"];
    [info setObject:[app objectForKey:@"DTPlatformVersion"] forKey:@"platformVersion"];
    UIDevice *device = [UIDevice currentDevice];
    [info setObject:device.systemName forKey:@"systemName"];
    [info setObject:device.systemVersion forKey:@"systemVersion"];
    
    return  info;
}

@end
