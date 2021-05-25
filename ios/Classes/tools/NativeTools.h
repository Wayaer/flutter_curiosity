#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@interface NativeTools : NSObject

//获取app信息
+ (NSDictionary *)getAppInfo;

//获取设备信息
+ (NSDictionary *)getDeviceInfo;

//调用系统分享
+ (void)openSystemShare:(FlutterMethodCall*)call result:(FlutterResult)result;

//跳转到APP权限设置页面
+ (BOOL)openAppSetting;

//判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
+ (BOOL)getGPSStatus;

//能否打开url
+ (BOOL) canOpenURL:(NSString *)url;
//打开url
+ (void) openURL:(NSDictionary *)arguments :(FlutterResult)result ;


@end
