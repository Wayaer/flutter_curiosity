
#import "AppInfo.h"

@implementation AppInfo
//获取app信息
+ (NSMutableDictionary *)getAppInfo;
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    NSDictionary *app = [[NSBundle mainBundle] infoDictionary];
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    [info setObject:@(rectStatus.size.height) forKey:@"StatusBarHeight"];
    [info setObject:@(rectStatus.size.width) forKey:@"StatusBarWidth"];
    
    [info setObject:NSHomeDirectory() forKey:@"HomeDirectory"];
    [info setObject:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] forKey:@"DocumentDirectory"];
    [info setObject:[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] forKey:@"LibraryDirectory"];
    [info setObject:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] forKey:@"CachesDirectory"];
    [info setObject:NSTemporaryDirectory() forKey:@"TemporaryDirectory"];
    
    [info setObject:[app objectForKey:@"CFBundleShortVersionString"] forKey:@"versionName"];
    [info setObject:@"Apple" forKey:@"phoneBrand"];
    [info setObject:[NSNumber numberWithInt:[[app objectForKey:@"CFBundleVersion"] intValue]] forKey:@"versionCode"];
    
    [info setObject:[app objectForKey:@"CFBundleIdentifier"] forKey:@"packageName"];
    [info setObject:[app objectForKey:@"CFBundleName"] forKey:@"AppName"];
    [info setObject:[app objectForKey:@"DTSDKBuild"] forKey:@"SDKBuild"];
    [info setObject:[app objectForKey:@"DTPlatformName"] forKey:@"PlatformName"];
    [info setObject:[app objectForKey:@"MinimumOSVersion"] forKey:@"MinimumOSVersion"];
    [info setObject:[app objectForKey:@"DTPlatformVersion"] forKey:@"PlatformVersion"];
    UIDevice *device = [UIDevice currentDevice];
    [info setObject:device.systemName forKey:@"systemName"];
    [info setObject:device.systemVersion forKey:@"systemVersion"];
    
    return  info;
}
@end
