
#import "Scanner.h"
#import "ScannerTools.h"
@interface Scanner()<AVCaptureMetadataOutputObjectsDelegate>

@property(nonatomic , strong)AVCaptureSession * session;
@property(nonatomic , strong)FlutterMethodChannel * _channel;
@property(nonatomic , strong)ScannerEventChannel * _event;
@property(nonatomic , strong)AVCaptureVideoPreviewLayer * captureLayer;
@property(nonatomic , strong)AVCaptureDevice * _device;

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;

@end

@implementation Scanner

- (AVCaptureSession *)session{
    if(!_session){
        _session=[[AVCaptureSession alloc]init];
    }
    return _session;
}

- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if(self = [super initWithFrame:frame]){
        
       NSString * channelName=[NSString stringWithFormat:@"scanner/%lld/method",viewId];
        self._channel=[FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [weakSelf._channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            [weakSelf onMethodCall:call result:result];
        }];
        
        NSString * eventChannelName=[NSString stringWithFormat:@"scanner/%lld/event",viewId];
        FlutterEventChannel * _evenChannel = [FlutterEventChannel eventChannelWithName:eventChannelName binaryMessenger:messenger];
        self._event=[ScannerEventChannel new];
        [_evenChannel setStreamHandler:self._event];
        
        AVCaptureVideoPreviewLayer * layer=[AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.captureLayer=layer;
        
        layer.backgroundColor=[UIColor blackColor].CGColor;
        [self.layer addSublayer:layer];
        layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
        
        self._device=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput * input=[[AVCaptureDeviceInput alloc] initWithDevice:self._device error:nil];
        AVCaptureMetadataOutput * output=[[AVCaptureMetadataOutput alloc]init];
        [self.session addInput:input];
        [self.session addOutput:output];
        self.session.sessionPreset=AVCaptureSessionPresetHigh;
        
        output.metadataObjectTypes=output.availableMetadataObjectTypes;
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [output setMetadataObjectTypes:@[AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeCode39Code,
                                         AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeDataMatrixCode,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeITF14Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeUPCECode]];
        
        [self.session startRunning];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.captureLayer.frame=self.bounds;
}

-(void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
 if ([call.method isEqualToString:@"setFlashMode"]){
        NSNumber * status = [call.arguments valueForKey:@"status"];
        result([NSNumber numberWithBool:[self setFlashMode:[status boolValue]]]);
    }else {
        result(FlutterMethodNotImplemented);
    }
}

-(void)resume{
    if(![self.session isRunning]){
        [self.session startRunning];
    }
}

-(void)pause{
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
}

-(BOOL)setFlashMode:(BOOL) status{
    [self._device lockForConfiguration:nil];
    BOOL isSuccess = YES;
    if ([self._device hasFlash]) {
        if (status) {
            self._device.flashMode=AVCaptureFlashModeOn;
            self._device.torchMode=AVCaptureTorchModeOn;
        }else{
            self._device.flashMode = AVCaptureFlashModeOff;
            self._device.torchMode = AVCaptureTorchModeOff;
        }
    }else{
        isSuccess=NO;
    }
    [self._device unlockForConfiguration];
    
    return isSuccess;
    
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        AVMetadataMachineReadableCodeObject * data=metadataObjects[0];
        NSString * value=data.stringValue;
        if(value.length&&self._event){
            [self._event getResult:[ScannerTools scanDataToMap:data]];
        }
    }
}
@end



@implementation ScannerEventChannel

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events{
    self.events = events;
    return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    if(self.scanner){
        [self.scanner pause];
    }
    return nil;
}

- (void)getResult:(NSDictionary *)msg{
    if(self.events){
        self.events(msg);
    }
}


@end
