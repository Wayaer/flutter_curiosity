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


//获取目录文件或文件夹大小
+ (NSString *)getFilePathSize:(NSString *)path{
    // 获取“path”文件夹下的所有文件
    NSArray *subPathArr = [[NSFileManager defaultManager] subpathsAtPath:path];
    NSString *filePath  = nil;
    NSInteger totalSize = 0;
    for (NSString *subPath in subPathArr){
        // 1. 拼接每一个文件的全路径
        filePath =[path stringByAppendingPathComponent:subPath];
        // 2. 是否是文件夹，默认不是
        BOOL isDirectory = [Tools isDirectory:path];
        // 3. 判断文件是否存在
        BOOL isExist = [Tools isDirectoryExist:path];
        // 4. 以上判断目的是忽略不需要计算的文件
        if (@available(macOS 10.10, *)) {
            if (!isExist || isDirectory || [filePath containsString:@".DS"]){
                // 过滤: 1. 文件夹不存在  2. 过滤文件夹  3. 隐藏文件
                continue;
            }
        }
        // 5. 指定路径，获取这个路径的属性
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        /**
         attributesOfItemAtPath: 文件夹路径
         该方法只能获取文件的属性, 无法获取文件夹属性, 所以也是需要遍历文件夹的每一个文件的原因
         */
        // 6. 获取每一个文件的大小
        if (@available(macOS 10.8, *)) {
            NSInteger size = [dict[@"NSFileSize"] integerValue];
            // 7. 计算总大小
            totalSize += size;
        } else {
            // Fallback on earlier versions
        }
    }
    //8. 将文件夹大小转换为 M/KB/B
    NSString *totalStr = nil;
    if (totalSize > 1000 * 1000){
        totalStr = [NSString stringWithFormat:@"%.2fMB",totalSize / 1000.00f /1000.00f];
        
    }else if (totalSize > 1000){
        totalStr = [NSString stringWithFormat:@"%.2fKB",totalSize / 1000.00f ];
        
    }else{
        totalStr = [NSString stringWithFormat:@"%.2fB",totalSize / 1.00f];
    }
    return totalStr;
}

//判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
+ (BOOL) getGPSStatus {
    if (@available(macOS 10.7, *)) {
        return [CLLocationManager locationServicesEnabled];
    }
    return  NO;
}

@end
