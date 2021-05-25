#import <Foundation/Foundation.h>
#import <FlutterMacOS/FlutterMacOS.h>
#import "Tools.h"

@interface NativeTools : NSObject

//获取app信息
+ (NSDictionary *)getAppInfo;

//判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
+ (BOOL)getGPSStatus;

@end
