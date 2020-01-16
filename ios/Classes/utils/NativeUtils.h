#import <Foundation/Foundation.h>

@interface NativeUtils : NSObject
//Log
+ (void)log:(id)props;
//获取Cookie
+ (void)setCookie:(NSDictionary *)props;
+ (void)clearAllCookie;
+ (NSMutableDictionary *)getAllCookie;

//跳转应用商店
+ (void)goToMarket:(NSString *)props;

// 删除沙盒指定文件夹和文件（删除文件夹）
+ (void)deleteFile:(NSString *)props;

// 删除沙盒指定文件夹内容（不删除文件夹）
+ (void)deleteFolder:(NSString *)props;

// 沙盒是否有指定文件夹
+ (BOOL)isFolderExists:(NSString *)props;

//获取文件或文件夹大小
+ (NSString *)getFilePathSize:(NSString *)props;


@end
