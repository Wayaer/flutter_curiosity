
#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>
@interface ScannerUtils : NSObject

//scan
+ (NSDictionary*) scanDataToMap:(AVMetadataMachineReadableCodeObject*) data;
+ (NSDictionary *) getCode:(NSData *)data;

+ (void) scanImagePath:(FlutterMethodCall*)call result:(FlutterResult)result;

+ (void) scanImageUrl:(FlutterMethodCall*)call result:(FlutterResult)result;

+ (void) scanImageMemory:(FlutterMethodCall*)call result:(FlutterResult)result;
@end


