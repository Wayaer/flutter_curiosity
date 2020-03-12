#import <Flutter/Flutter.h>
#import "NativeUtils.h"
#import "FileUtils.h"
#import "PicturePicker.h"
#import "AppInfo.h"

@interface CuriosityPlugin : NSObject<FlutterPlugin>

+(void) registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;

@end
