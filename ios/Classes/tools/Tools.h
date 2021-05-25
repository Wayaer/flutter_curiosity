#import <Foundation/Foundation.h>

@interface Tools : NSObject

//Log
+ (void)log:(id)props;

//返回标识信息
+ (NSString *)resultInfo:(NSString *)info;
+ (NSString *)resultFail;
+ (NSString *)resultSuccess;

//是否是图片
+ (BOOL)isImageFile:(NSString *)path;

//是否是模拟器
+ (BOOL)isEmulator;

@end
