#import "Tools.h"
#define fileManager [NSFileManager defaultManager]

@implementation Tools

//Log
+ (void)log:(id)info{
    NSLog(@"CuriosityLog = %@", info);
}

+ (NSString *)resultInfo:(NSString *)info{
    return [NSString stringWithFormat:@"Curiosity:%@",info];
}

+ (NSString *)resultFail{
    return @"Curiosity:fail";
}
+ (NSString *)resultSuccess{
    return @"Curiosity:success";
}
// 沙盒是否有指定路径文件夹或文件
+(BOOL)isDirectoryExist:(NSString *)path {
    return [fileManager fileExistsAtPath:path];
}
// 是否是文件夹
+ (BOOL) isDirectory:(NSString *)path{
    BOOL isDir = NO;
    [fileManager fileExistsAtPath:path isDirectory:&isDir];
    return isDir;
}

+(BOOL) isImageFile:(NSString *)path{
    return [path hasSuffix:@".jpg"]
    ||[path hasSuffix:@".png"]
    ||[path hasSuffix:@".PNG"]
    ||[path hasSuffix:@".JPEG"]
    ||[path hasSuffix:@".JPG"]
    ||[path hasSuffix:@".GiF"]
    ||[path hasSuffix:@".gif"];
}
+(BOOL)isEmulator{
    if (TARGET_IPHONE_SIMULATOR == 1 && TARGET_OS_IPHONE == 1) {
        return YES;
    }else{
        return NO;
    }
}

@end
