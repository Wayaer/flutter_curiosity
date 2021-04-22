#import <Foundation/Foundation.h>
#import <FlutterMacOS/FlutterMacOS.h>
#import "Tools.h"

@interface NativeTools : NSObject

//跳转拨号
//+ (void)callPhone:(NSString *)phoneNumber;

//获取app信息
+ (NSDictionary *)getAppInfo;


//跳转到APP权限设置页面
//+ (BOOL)jumpAppSetting;

//判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
+ (BOOL)getGPSStatus;

// 获取文件或文件夹大小
+ (NSString *)getFilePathSize:(NSString *)props;

// 解压文件
//+ (NSString *)unZipFile:(NSString *)props;

@end
