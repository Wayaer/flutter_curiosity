#import "GPSTools.h"
#ifdef COCOAPODS
@import CoreLocation;
#else
#import <CoreLocation/CoreLocation.h>
#endif

@interface GPSTools()
@property (strong, nonatomic) CLLocationManager *clLocationManager;
@property (assign, nonatomic) BOOL               locationWanted;
@property (assign, nonatomic) BOOL               permissionWanted;

@end
@implementation GPSTools


//强制帮用户打开GPS
+ (void) open {
    
    
}

//跳转到设置页面让用户自己手动开启
+ (void) jumpSetting {
    NSURL *url = [[NSURL alloc] initWithString:UIApplicationOpenSettingsURLString];
    if( [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}
//判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
+ (BOOL) getStatus {
    return [CLLocationManager locationServicesEnabled];
}

@end
