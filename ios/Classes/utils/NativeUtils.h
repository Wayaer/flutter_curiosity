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

@end
