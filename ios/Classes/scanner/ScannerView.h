#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>

API_AVAILABLE(ios(10.0))
@interface ScannerView : NSObject<FlutterTexture,FlutterStreamHandler,AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>


@property(readonly, nonatomic) CGSize previewSize;

@property(nonatomic) FlutterEventChannel *eventChannel;

//第一帧回掉
@property(nonatomic, copy) void (^onFrameAvailable)(void);

- (instancetype)initWitchCamera:(NSString*)cameraId :(NSString*)resolutionPreset :(NSError **)error;

- (BOOL)setFlashMode:(BOOL)status;

- (void)start;

- (void)close;

@end

