#import "Tools.h"

#define fileManager [NSFileManager defaultManager]
@implementation Tools

//Log
+ (void)log:(id)info{
    NSLog(@"CuriosityLog = %@", info);
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
    ||[path hasSuffix:@".JPEG"]
    ||[path hasSuffix:@".JPG"]
    ||[path hasSuffix:@".PNG"];
}


@end
