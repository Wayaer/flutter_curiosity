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


//强制帮用户打开GPS
+ (void)open;

//跳转到设置页面让用户自己手动开启
+ (void)jumpGPSSetting;

//判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
+ (BOOL)getGPSStatus;

@end
