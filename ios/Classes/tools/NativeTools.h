#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@interface NativeTools : NSObject
//Log
+ (void)log:(id)props;

//跳转应用商店
+ (void)goToMarket:(NSString *)props;

//跳转拨号
+ (void)callPhone:(NSString *)phoneNumber :(NSNumber *)directDial;

//获取app信息
+ (NSMutableDictionary *)getAppInfo;

//调用系统分享
+ (void)systemShare:(FlutterMethodCall*)call result:(FlutterResult)result;
@end
