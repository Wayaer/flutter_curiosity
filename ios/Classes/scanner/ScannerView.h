#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>
#import "NativeTools.h"
@interface ScannerView : NSObject<AVCaptureMetadataOutputObjectsDelegate,FlutterTexture,AVCaptureVideoDataOutputSampleBufferDelegate>

@property(nonatomic) FlutterEventSink eventSink;

@property(readonly, nonatomic) CGSize previewSize;

//第一帧回掉
@property(nonatomic, copy) void (^onFrameAvailable)(void);

- (instancetype)initWitchCamera:(NSString*)cameraId :(NSString*)resolutionPreset :(NSError **)error;

- (BOOL)setFlashMode:(BOOL)status;

- (void)start;

- (void)close;

@end

