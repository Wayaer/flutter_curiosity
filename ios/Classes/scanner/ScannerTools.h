
#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>
@interface ScannerTools : NSObject

//scan
+ (NSDictionary*) scanDataToMap:(AVMetadataMachineReadableCodeObject*)data;

+ (NSDictionary *) getCode:(NSData *)data;

+ (void) scanImagePath:(FlutterMethodCall*)call result:(FlutterResult)result;

+ (void) scanImageUrl:(FlutterMethodCall*)call result:(FlutterResult)result;

+ (void) scanImageMemory:(FlutterMethodCall*)call result:(FlutterResult)result;

+ (void)setCaptureSessionPreset:(NSString *)resolutionPreset :(AVCaptureSession*)captureSession :(AVCaptureDevice*)captureDevice  :(CGSize)previewSize;

 //获取可用的摄像头
+(void)availableCameras:(FlutterMethodCall *)call result:(FlutterResult)result;

@end


