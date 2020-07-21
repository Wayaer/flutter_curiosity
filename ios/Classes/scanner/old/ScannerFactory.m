
#import "ScannerFactory.h"
#import "Scanner.h"

static NSString * scanView=@"scanView";

@implementation ScannerFactory{
 
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
    ScannerPlatformView * scanner=[[ScannerPlatformView alloc]initWithFrame:frame viewindentifier:viewId arguments:args binaryMessenger:_messenger];
    return scanner;
    
}
@end

@interface ScannerPlatformView()
@property(nonatomic , strong)Scanner * view;


@end
@implementation ScannerPlatformView{

}

- (instancetype)initWithFrame:(CGRect)frame viewindentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if(self = [super init]){
        _view=[[Scanner alloc]initWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:messenger];
        _view.backgroundColor=[UIColor clearColor];
        _view.frame=frame;
        
    }
    return self;
}
- (nonnull UIView *)view {
    return _view;
}


@end



