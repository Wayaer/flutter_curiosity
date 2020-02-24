
#import "ScanView.h"
#import "ScanUtils.h"

@implementation ScanUtils
+ (void)scanImagePath:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSString * path=[call.arguments valueForKey:@"path"];
    if([path isKindOfClass:[NSNull class]]){
        result(@"");
        return;
    }
    //加载文件
    NSFileHandle * fh=[NSFileHandle fileHandleForReadingAtPath:path];
    NSData * data=[fh readDataToEndOfFile];
    result([self getQrCode:data]);
}

+ (void)scanImageUrl:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSString * url = [call.arguments valueForKey:@"url"];
    NSURL* nsUrl=[NSURL URLWithString:url];
    NSData * data=[NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:nsUrl] returningResponse:nil error:nil];
    result([ScanUtils getQrCode:data]);
}

+ (void)scanImageMemory:(FlutterMethodCall*)call result:(FlutterResult)result{
    FlutterStandardTypedData * uint8list=[call.arguments valueForKey:@"uint8list"];
    result([ScanUtils getQrCode:uint8list.data]);
}

+(NSDictionary*) pointsToMap:(CGPoint) point{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setValue:@(point.x) forKey:@"X"];
    [dict setValue:@(point.y) forKey:@"Y"];
    return dict;
}

+(NSDictionary *) getQrCode:(NSData *)data{
    if (data) {
        CIImage * detectImage=[CIImage imageWithData:data];
        CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
        NSArray* feature = [detector featuresInImage:detectImage options: nil];
        if(feature.count==0){
            return nil;
        }else{
            for(int index=0;index<[feature count];index ++){
                CIQRCodeFeature * qrCode=[feature objectAtIndex:index];
                NSString *resultStr=qrCode.messageString;
                if(resultStr!=nil){
                    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
                    [dict setValue:resultStr forKey:@"message"];
                    [dict setValue:[ScanUtils getType:AVMetadataObjectTypeQRCode] forKey:@"type"];
                    NSMutableArray<NSDictionary *> * points = [NSMutableArray array];
                    CGPoint topLeft=qrCode.topLeft;
                    CGPoint topRight=qrCode.topRight;
                    CGPoint bottomLeft=qrCode.bottomLeft;
                    CGPoint bottomRight=qrCode.bottomRight;
                    [points addObject:[self pointsToMap:topLeft]];
                     [points addObject:[self pointsToMap:topRight]];
                     [points addObject:[self pointsToMap:bottomLeft]];
                     [points addObject:[self pointsToMap:bottomRight]];
                    [dict setValue:points forKey:@"points"];
                    return dict;
                }
                
            }
        }
    }
    return nil;
}

+(NSDictionary*) toMap:(AVMetadataMachineReadableCodeObject*) obj{
    if (obj == nil) {
        return nil;
    }
    NSMutableDictionary * result =[NSMutableDictionary dictionary];
    [result setValue:obj.stringValue forKey:@"message"];
    [result setValue:[self getType:obj.type] forKey:@"type"];
    [result setValue:obj.corners forKey:@"points"];
    return result;
}

+(NSNumber*) getType:(AVMetadataObjectType)type{
    if (type == AVMetadataObjectTypeAztecCode) {
        return @(0);
    }else if (type == AVMetadataObjectTypeCode39Code) {
        return @(2);
    }else if (type == AVMetadataObjectTypeCode93Code) {
        return @(3);
    }else if (type == AVMetadataObjectTypeCode128Code) {
        return @(4);
    }else if (type == AVMetadataObjectTypeDataMatrixCode) {
        return @(5);
    }else if (type == AVMetadataObjectTypeEAN8Code) {
        return @(6);
    }else if (type == AVMetadataObjectTypeEAN13Code) {
        return @(7);
    }else if (type == AVMetadataObjectTypeITF14Code) {
        return @(8);
    }else if (type == AVMetadataObjectTypePDF417Code) {
        return @(10);
    }else if (type == AVMetadataObjectTypeQRCode) {
        return @(11);
    }else if (type == AVMetadataObjectTypeUPCECode) {
        return @(15);
    }else{
        return nil;
    }
}
@end
