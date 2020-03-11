
#import "ScanView.h"
#import "ScanUtils.h"
@interface ScanView()<AVCaptureMetadataOutputObjectsDelegate>

@property(nonatomic , strong)AVCaptureSession * session;
@property(nonatomic , strong)FlutterMethodChannel * _channel;
@property(nonatomic , strong)ScanViewEventChannel * _event;
@property(nonatomic , strong)AVCaptureVideoPreviewLayer * captureLayer;
@property(nonatomic , strong)AVCaptureDevice * _device;

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;

@end

@implementation ScanView

- (AVCaptureSession *)session{
    if(!_session){
        _session=[[AVCaptureSession alloc]init];
    }
    return _session;
}

- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if(self = [super initWithFrame:frame]){
        
       NSString * channelName=[NSString stringWithFormat:@"scanView/%lld/method",viewId];
        self._channel=[FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [weakSelf._channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            [weakSelf onMethodCall:call result:result];
        }];
        
        NSString * eventChannelName=[NSString stringWithFormat:@"scanView/%lld/event",viewId];
        FlutterEventChannel * _evenChannel = [FlutterEventChannel eventChannelWithName:eventChannelName binaryMessenger:messenger];
        self._event=[ScanViewEventChannel new];
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
    if ([call.method isEqualToString:@"startScan"]) {
        [self resume];
        result(nil);
    }else if([call.method isEqualToString:@"stopScan"]){
        [self pause];
        result(nil);
    }else if ([call.method isEqualToString:@"setFlashMode"]){
        NSNumber * status = [call.arguments valueForKey:@"status"];
        result([NSNumber numberWithBool:[self setFlashMode:[status boolValue]]]);
    }else if ([call.method isEqualToString:@"getFlashMode"]){
        result([NSNumber numberWithBool:[self getFlashMode]]);
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
-(BOOL)getFlashMode{
    [self._device lockForConfiguration:nil];
    BOOL isSuccess = self._device.flashMode==AVCaptureFlashModeOn&&
    self._device.torchMode==AVCaptureTorchModeOn;
    [self._device unlockForConfiguration];
    return isSuccess;
    
}
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        AVMetadataMachineReadableCodeObject * data=metadataObjects[0];
        NSString * value=data.stringValue;
        if(value.length&&self._event){
            [self._event getResult:[ScanUtils scanDataToMap:data]];
        }
    }
}
@end



@implementation ScanViewEventChannel

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events{
    self.events = events;
    if(self.scanView){
        NSNumber * isScan=[arguments valueForKey:@"isScan"];
        if(isScan){
            if (isScan.boolValue) {
                [self.scanView resume];
            }else{
                [self.scanView pause];
            }
        }
    }
    return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    if(self.scanView){
        [self.scanView pause];
    }
    return nil;
}

- (void)getResult:(NSDictionary *)msg{
    if(self.events){
        self.events(msg);
    }
}


@end
