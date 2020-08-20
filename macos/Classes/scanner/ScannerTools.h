#import <FlutterMacOS/FlutterMacOS.h>
#import <AVFoundation/AVFoundation.h>
#import "Tools.h"

@interface ScannerTools : NSObject

//scan
+ (NSDictionary*) scanDataToMap:(AVMetadataMachineReadableCodeObject*)data API_AVAILABLE(macos(10.15));

+ (NSDictionary *) getCode:(NSData *)data;

+ (void) scanImagePath:(FlutterMethodCall*)call result:(FlutterResult)result;

+ (void) scanImageUrl:(FlutterMethodCall*)call result:(FlutterResult)result;

+ (void) scanImageMemory:(FlutterMethodCall*)call result:(FlutterResult)result;

//获取可用的摄像头
+(void) availableCameras:(FlutterMethodCall *)call result:(FlutterResult)result;

@end


