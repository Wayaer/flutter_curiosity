#import <Foundation/Foundation.h>

@interface GPSTools : NSObject
//强制帮用户打开GPS
+ (void)open;
//跳转到设置页面让用户自己手动开启
+ (void)jumpSetting;
//判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
+ (BOOL)getStatus;

@end


