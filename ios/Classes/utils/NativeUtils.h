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

//跳转拨号
+ (void)callPhone:(NSString *)phoneNumber :(BOOL)directDial;
@end
