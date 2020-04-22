#import <Foundation/Foundation.h>

@interface NativeTools : NSObject
//Log
+ (void)log:(id)props;

//跳转应用商店
+ (void)goToMarket:(NSString *)props;

//跳转拨号
+ (void)callPhone:(NSString *)phoneNumber :(NSNumber *)directDial;

//获取app信息
+ (NSMutableDictionary *)getAppInfo;

@end
