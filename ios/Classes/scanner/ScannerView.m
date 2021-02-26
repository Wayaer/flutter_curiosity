#import "ScannerView.h"
#import <CoreMotion/CoreMotion.h>
#import <libkern/OSAtomic.h>
#import "ScannerTools.h"


@implementation ScannerView{
    //链接相机用的
    AVCaptureSession *_captureSession;
    //获取相机设备
    AVCaptureDevice *_captureDevice;
    //视频输入
    AVCaptureInput *_captureVideoInput;
    //视频输出
    AVCaptureMetadataOutput *_captureOutput;
    //视频输出2
    AVCaptureVideoDataOutput *_captureVideoOutput;
    
    CVPixelBufferRef volatile _latestPixelBuffer;
    
    FlutterEventSink eventSink;
    
    FlutterEventChannel *eventChannel;
}

FourCharCode const videoFormat = kCVPixelFormatType_32BGRA;
- (instancetype)initWitchCamera:(NSString*)cameraId
                               :(FlutterEventChannel*)_eventChannel
                               :(NSString*)resolutionPreset
                               :(NSError **)error{
    self = [super init];
    eventChannel=_eventChannel;
    
    NSAssert(self, @"super init cannot be nil");
    _captureSession = [[AVCaptureSession alloc]init];
    _captureDevice = [AVCaptureDevice deviceWithUniqueID:cameraId];
    
    NSError *localError =nil;
    _captureVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:&localError];
    
    if(localError){
        *error = localError;
        return nil;
    }
    
    _captureVideoOutput = [AVCaptureVideoDataOutput new];
    _captureVideoOutput.videoSettings = @{(NSString*)kCVPixelBufferPixelFormatTypeKey: @(videoFormat)};
    [_captureVideoOutput setAlwaysDiscardsLateVideoFrames:YES];
    [_captureVideoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    //链接
    AVCaptureConnection* connection =[AVCaptureConnection connectionWithInputPorts:_captureVideoInput.ports output:_captureVideoOutput];
    
    if ([_captureDevice position] == AVCaptureDevicePositionFront) {
        connection.videoMirrored = YES;
    }
    if([connection isVideoOrientationSupported]){
        connection.videoOrientation =AVCaptureVideoOrientationPortrait;
    }
    [_captureSession addInputWithNoConnections:_captureVideoInput];
    [_captureSession addOutputWithNoConnections:_captureVideoOutput];
    
    _captureOutput=[[AVCaptureMetadataOutput alloc]init];
    
    //设置代理，在主线程刷新
    [_captureOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_captureSession addOutput:_captureOutput];
    _captureOutput.metadataObjectTypes=_captureOutput.availableMetadataObjectTypes;
    //扫码区域的大小
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    layer.frame = CGRectMake(left, top, size, size);
//    [_captureOutput rectOfInterest];
    [_captureOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_captureOutput setMetadataObjectTypes:@[AVMetadataObjectTypeAztecCode,
                                             AVMetadataObjectTypeCode39Code,
                                             AVMetadataObjectTypeCode93Code,
                                             AVMetadataObjectTypeCode128Code,
                                             AVMetadataObjectTypeDataMatrixCode,
                                             AVMetadataObjectTypeEAN8Code,
                                             AVMetadataObjectTypeEAN13Code,
                                             AVMetadataObjectTypeITF14Code,
                                             AVMetadataObjectTypePDF417Code,
                                             AVMetadataObjectTypeQRCode,
                                             AVMetadataObjectTypeUPCECode]];
    [_captureSession addConnection:connection];
    [self setCaptureSessionPreset:resolutionPreset];
    return self;
}


- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        AVMetadataMachineReadableCodeObject * metaObject=metadataObjects[0];
        if(eventSink)eventSink([ScannerTools scanDataToMap:metaObject]);
    }
    
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if (output == _captureVideoOutput) {
        CVPixelBufferRef newBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CFRetain(newBuffer);
        CVPixelBufferRef old = _latestPixelBuffer;
        while (!OSAtomicCompareAndSwapPtrBarrier(old, newBuffer, (void **)&_latestPixelBuffer)) {
            old = _latestPixelBuffer;
        }
        if (old != nil)
            CFRelease(old);
        if (_onFrameAvailable)_onFrameAvailable();
        
    }
}


- (void)start{
    [_captureSession startRunning];
}

-(void)resume{
    if(![_captureSession isRunning])
        [_captureSession startRunning];
    
}

-(void)pause{
    if ([_captureSession isRunning])
        [_captureSession stopRunning];
    
}

//打开/关闭 闪光灯
-(BOOL)setFlashMode:(BOOL) status{
    [_captureDevice lockForConfiguration:nil];
    BOOL isSuccess = YES;
    if ([_captureDevice hasFlash]) {
        if (status) {
            _captureDevice.flashMode = AVCaptureFlashModeOn;
            _captureDevice.torchMode = AVCaptureTorchModeOn;
        }else{
            _captureDevice.flashMode = AVCaptureFlashModeOff;
            _captureDevice.torchMode = AVCaptureTorchModeOff;
        }
    }else{
        isSuccess=NO;
    }
    [_captureDevice unlockForConfiguration];
    return isSuccess;
    
}

- (void)close {
    eventSink = nil;
    [eventChannel setStreamHandler:nil];
    eventChannel=nil;
    
    [_captureSession stopRunning];
    for (AVCaptureInput *input in [_captureSession inputs]) {
        [_captureSession removeInput:input];
    }
    for (AVCaptureOutput *output in [_captureSession outputs]) {
        [_captureSession removeOutput:output];
    }
}
- (CVPixelBufferRef _Nullable)copyPixelBuffer {
    CVPixelBufferRef pixelBuffer = _latestPixelBuffer;
    while (!OSAtomicCompareAndSwapPtrBarrier(pixelBuffer, nil, (void **)&_latestPixelBuffer)) {
        pixelBuffer = _latestPixelBuffer;
    }
    return pixelBuffer;
}


- (void)setCaptureSessionPreset:(NSString *)resolutionPreset {
    if ([@"max" isEqualToString:resolutionPreset]) {
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
            _previewSize = CGSizeMake(_captureDevice.activeFormat.highResolutionStillImageDimensions.width,
                                      _captureDevice.activeFormat.highResolutionStillImageDimensions.height);
        }
    }else if ([@"ultraHigh" isEqualToString:resolutionPreset]) {
        if (@available(iOS 9.0, *)) {
            if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset3840x2160]) {
                _captureSession.sessionPreset = AVCaptureSessionPreset3840x2160;
                _previewSize = CGSizeMake(3840, 2160);
            }
        } else {
            // Fallback on earlier versions
        }
    }else if ([@"veryHigh" isEqualToString:resolutionPreset]) {
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            _captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
            _previewSize = CGSizeMake(1920, 1080);
            
        }
    }else if ([@"high" isEqualToString:resolutionPreset]) {
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
            _previewSize = CGSizeMake(1280, 720);
        }
    }else if ([@"medium" isEqualToString:resolutionPreset]) {
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
            _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
            _previewSize = CGSizeMake(640, 480);
            
        }
    }else  if ([@"low" isEqualToString:resolutionPreset]) {
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset352x288]) {
            _captureSession.sessionPreset = AVCaptureSessionPreset352x288;
            _previewSize = CGSizeMake(352, 288);
        }
    }else{
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetLow]) {
            _captureSession.sessionPreset = AVCaptureSessionPresetLow;
            _previewSize = CGSizeMake(352, 288);
        } else {
            NSError *error =
            [NSError errorWithDomain:NSCocoaErrorDomain
                                code:NSURLErrorUnknown
                            userInfo:@{
                                NSLocalizedDescriptionKey :
                                    @"No capture session available for current capture session."
                            }];
            @throw error;
        }
    }
    
}
- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    eventSink = nil;
    [eventChannel setStreamHandler:nil];
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    eventSink = events;
    return nil;
}
@end


