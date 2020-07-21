#import <Flutter/Flutter.h>

@interface CuriosityPlugin : NSObject<FlutterPlugin,FlutterStreamHandler>

+(void) registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;

@end
