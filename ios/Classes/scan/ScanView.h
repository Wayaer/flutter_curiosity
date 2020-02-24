
#import <UiKit/UiKit.h>
#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>

@interface ScanView : UIView

-(instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger;


@end

@interface ScanViewEventChannel : NSObject<FlutterStreamHandler>

@property(nonatomic , strong)FlutterEventSink events;
@property(nonatomic , strong)ScanView* scanView;

-(void)getResult:(NSDictionary *)msg;


@end
