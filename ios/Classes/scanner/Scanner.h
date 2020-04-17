
#import <UiKit/UiKit.h>
#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>

@interface Scanner : UIView

-(instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger;


@end

@interface ScannerEventChannel : NSObject<FlutterStreamHandler>

@property(nonatomic , strong)FlutterEventSink events;
@property(nonatomic , strong)Scanner* scanner;

-(void)getResult:(NSDictionary *)msg;


@end
