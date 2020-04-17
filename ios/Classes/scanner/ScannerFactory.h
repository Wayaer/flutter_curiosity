#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>

@interface ScannerPlatformView : NSObject<FlutterPlatformView>

-(instancetype _Nullable )initWithFrame:(CGRect)frame viewindentifier:(int64_t)viewId arguments:(id _Nullable)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *_Nonnull)messenger;

-(nonnull UIView*) view;

@end

@interface ScannerFactory : NSObject<FlutterPlatformViewFactory>

-(instancetype _Nullable )initWithMessenger:(NSObject<FlutterBinaryMessenger>*_Nonnull)messenger;

@end




