#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>

@interface ScanPlatformView : NSObject<FlutterPlatformView>

-(instancetype _Nullable )initWithFrame:(CGRect)frame viewindentifier:(int64_t)viewId arguments:(id _Nullable)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *_Nonnull)messenger;

-(nonnull UIView*) view;

@end

@interface ScanViewFactory : NSObject<FlutterPlatformViewFactory>

-(instancetype _Nullable )initWithMessenger:(NSObject<FlutterBinaryMessenger>*_Nonnull)messenger;

@end




