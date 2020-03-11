
#import "ScanView.h"
#import "ScanUtils.h"

@implementation ScanUtils
+ (void)scanImagePath:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSString * path=[call.arguments valueForKey:@"path"];
    if([path isKindOfClass:[NSNull class]]){
        result(nil);
        return;
    }
    //加载文件
    NSFileHandle * fh=[NSFileHandle fileHandleForReadingAtPath:path];
    NSData * data=[fh readDataToEndOfFile];
    result([self getCode:data]);
}

+ (void)scanImageUrl:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSString * url = [call.arguments valueForKey:@"url"];
    NSURL* nsUrl=[NSURL URLWithString:url];
    NSData * data=[NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:nsUrl] returningResponse:nil error:nil];
    result([self getCode:data]);
}

+ (void)scanImageMemory:(FlutterMethodCall*)call result:(FlutterResult)result{
    FlutterStandardTypedData * uint8list=[call.arguments valueForKey:@"uint8list"];
    result([self getCode:uint8list.data]);
}

+(NSDictionary *) getCode:(NSData *)data{
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
                    [dict setValue:resultStr forKey:@"code"];
                    [dict setValue:AVMetadataObjectTypeQRCode forKey:@"type"];
                    return dict;
                }
                
            }
        }
    }
    return nil;
}

+(NSDictionary*) scanDataToMap:(AVMetadataMachineReadableCodeObject*) data{
    if (data == nil) {
        return nil;
    }
    NSMutableDictionary * result =[NSMutableDictionary dictionary];
    [result setValue:data.stringValue forKey:@"code"];
     [result setValue:data.type forKey:@"type"];
    return result;
}

@end
