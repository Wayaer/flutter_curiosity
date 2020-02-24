
#import "ScanViewFactory.h"
#import "ScanView.h"

static NSString * scanView=@"scanView";

@implementation ScanViewFactory{
 
    NSObject<FlutterBinaryMessenger>* _messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    self = [super init];
    if (self) {
        _messenger=messenger;
    }
    return self;
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}
- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args{
    ScanPlatformView * scanView=[[ScanPlatformView alloc]initWithFrame:frame viewindentifier:viewId arguments:args binaryMessenger:_messenger];
    return scanView;
    
}
@end

@interface ScanPlatformView()
@property(nonatomic , strong)ScanView * view;


@end
@implementation ScanPlatformView{

}

- (instancetype)initWithFrame:(CGRect)frame viewindentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if(self = [super init]){
        _view=[[ScanView alloc]initWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:messenger];
        _view.backgroundColor=[UIColor clearColor];
        _view.frame=frame;
        
    }
    return self;
}
- (nonnull UIView *)view {
    return _view;
}


@end



