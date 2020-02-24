
#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>
@interface ScanUtils : NSObject

//scan
+ (NSDictionary*) toMap:(AVMetadataMachineReadableCodeObject*) obj;
+ (NSNumber*) getType:(AVMetadataObjectType)type;
+ (NSDictionary*) pointsToMap:(CGPoint) point;
+ (NSDictionary *) getQrCode:(NSData *)data;

+ (void) scanImagePath:(FlutterMethodCall*)call result:(FlutterResult)result;

+ (void) scanImageUrl:(FlutterMethodCall*)call result:(FlutterResult)result;

+ (void) scanImageMemory:(FlutterMethodCall*)call result:(FlutterResult)result;
@end


