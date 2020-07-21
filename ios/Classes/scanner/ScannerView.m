#import "ScannerView.h"
#import <CoreMotion/CoreMotion.h>
#import <libkern/OSAtomic.h>
#import "ScannerTools.h"


@implementation ScannerView{
  
    //链接相机用的
    AVCaptureSession *captureSession;
    //获取相机设备
    AVCaptureDevice *captureDevice;
    //视频输入
    AVCaptureInput *captureVideoInput;
    //视频输出
    AVCaptureMetadataOutput * captureOutput;
    //视频输出2
    AVCaptureVideoDataOutput *captureVideoOutput;
//    CGSize previewSize;
    //channel用于返回数据给data
//    FlutterEventSink eventSink;
    CVPixelBufferRef volatile latestPixelBuffer;
}

FourCharCode const scannerViewFormat = kCVPixelFormatType_32BGRA;
- (instancetype)initWitchCamera:(NSString*)cameraId :(NSString*)resolutionPreset :(NSError **)error{
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
  
    captureSession = [[AVCaptureSession alloc]init];
    captureDevice = [AVCaptureDevice deviceWithUniqueID:cameraId];
    
    NSError *localError =nil;
    captureVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&localError];
    
    if(localError){
        *error = localError;
        return nil;
    }
    
    captureVideoOutput = [AVCaptureVideoDataOutput new];
    captureVideoOutput.videoSettings = @{(NSString*)kCVPixelBufferPixelFormatTypeKey: @(scannerViewFormat)};
    [captureVideoOutput setAlwaysDiscardsLateVideoFrames:YES];
    [captureVideoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    //链接
    AVCaptureConnection* connection =[AVCaptureConnection connectionWithInputPorts:captureVideoInput.ports output:captureVideoOutput];
    
    if ([captureDevice position] == AVCaptureDevicePositionFront) {
        connection.videoMirrored = YES;
    }
    if([connection isVideoOrientationSupported]){
        connection.videoOrientation =AVCaptureVideoOrientationPortrait;
    }
    [captureSession addInputWithNoConnections:captureVideoInput];
    [captureSession addOutputWithNoConnections:captureVideoOutput];
    
    captureOutput=[[AVCaptureMetadataOutput alloc]init];
    
    
    //设置代理，在主线程刷新
    [captureOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [captureSession addOutput:captureOutput];
    captureOutput.metadataObjectTypes=captureOutput.availableMetadataObjectTypes;
    //扫码区域的大小
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //    layer.frame = CGRectMake(left, top, size, size);
    //        [_captureOutput rectOfInterest];
    [captureOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [captureOutput setMetadataObjectTypes:@[AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeCode39Code,
                                            AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeDataMatrixCode,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeITF14Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeUPCECode]];
    [captureSession addConnection:connection];
    [ScannerTools setCaptureSessionPreset:resolutionPreset :captureSession :captureDevice :_previewSize];
    [NativeTools log:@"原生初始化相机完成"];
    return self;
}


- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        AVMetadataMachineReadableCodeObject * metaObject=metadataObjects[0];
        if(_eventSink)_eventSink([ScannerTools scanDataToMap:metaObject]);
    }
    
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if (output == captureVideoOutput) {
        CVPixelBufferRef newBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CFRetain(newBuffer);
        CVPixelBufferRef old = latestPixelBuffer;
        while (!OSAtomicCompareAndSwapPtrBarrier(old, newBuffer, (void **)&latestPixelBuffer)) {
            old = latestPixelBuffer;
        }
        if (old != nil)
            CFRelease(old);
        if (_onFrameAvailable)
            _onFrameAvailable();
        
    }
}


- (void)start{
    [captureSession startRunning];
    [NativeTools log:@"原生相机开始完成"];
}

-(void)resume{
    if(![captureSession isRunning]){
        [captureSession startRunning];
    }
}

-(void)pause{
    if ([captureSession isRunning]) {
        [captureSession stopRunning];
    }
}

//打开/关闭 闪光灯
-(BOOL)setFlashMode:(BOOL) status{
    [captureDevice lockForConfiguration:nil];
    BOOL isSuccess = YES;
    if ([captureDevice hasFlash]) {
        if (status) {
            captureDevice.flashMode = AVCaptureFlashModeOn;
            captureDevice.torchMode = AVCaptureTorchModeOn;
        }else{
            captureDevice.flashMode = AVCaptureFlashModeOff;
            captureDevice.torchMode = AVCaptureTorchModeOff;
        }
    }else{
        isSuccess=NO;
    }
    [captureDevice unlockForConfiguration];
    return isSuccess;
    
}

- (void)close {
    [captureSession stopRunning];
    for (AVCaptureInput *input in [captureSession inputs]) {
        [captureSession removeInput:input];
    }
    for (AVCaptureOutput *output in [captureSession outputs]) {
        [captureSession removeOutput:output];
    }
}
- (CVPixelBufferRef _Nullable)copyPixelBuffer {
    CVPixelBufferRef pixelBuffer = latestPixelBuffer;
    while (!OSAtomicCompareAndSwapPtrBarrier(pixelBuffer, nil, (void **)&latestPixelBuffer)) {
        pixelBuffer = latestPixelBuffer;
    }
    return pixelBuffer;
}

@end


