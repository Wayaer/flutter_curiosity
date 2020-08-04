#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface CuriosityPlugin : NSObject<FlutterPlugin,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

+(void) registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;

@end

NS_ASSUME_NONNULL_END
