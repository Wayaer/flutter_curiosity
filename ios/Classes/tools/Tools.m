#import "Tools.h"
#define fileManager [NSFileManager defaultManager]

@implementation Tools

//Log
+ (void)log:(id)info{
    NSLog(@"CuriosityLog = %@", info);
}

+ (NSString *)resultInfo:(NSString *)info{
    return [NSString stringWithFormat:@"%@",info];
}

+ (NSString *)resultFail{
    return @"fail";
}
+ (NSString *)resultSuccess{
    return @"success";
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
    } else {
        return NO;
    }
}

@end
