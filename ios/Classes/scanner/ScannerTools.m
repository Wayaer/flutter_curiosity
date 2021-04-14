#import "ScannerTools.h"

@implementation ScannerTools

+ (void)scanImagePath:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSString * path=[call.arguments valueForKey:@"path"];
    if([path isKindOfClass:[NSNull class]]){
        result(nil);
        return;
    }
    NSFileHandle * fh=[NSFileHandle fileHandleForReadingAtPath:path];
    NSData * data=[fh readDataToEndOfFile];
    result([self getCode:data]);
}

+ (void)scanImageUrl:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSString * url = [call.arguments valueForKey:@"url"];
    NSURL* nsUrl=[NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsUrl];
    NSURLSessionDataTask * dataTask = [
                                       [NSURLSession sharedSession]
                                       dataTaskWithRequest:request
                                       completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data == nil) {
            result(nil);
            return;
        }
        result([self getCode:data]);
    }];
    [dataTask resume];
    
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
    if (data == nil)return nil;
    NSMutableDictionary * result =[NSMutableDictionary dictionary];
    [result setValue:data.stringValue forKey:@"code"];
    [result setValue:data.type forKey:@"type"];
    return result;
}


/**
 获取可用的摄像头
 */
+(void)availableCameras:(FlutterMethodCall *)call result:(FlutterResult)result{
    if (@available(iOS 10.0, *)) {
        AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession
                                                             discoverySessionWithDeviceTypes:@[ AVCaptureDeviceTypeBuiltInWideAngleCamera ]
                                                             mediaType:AVMediaTypeVideo
                                                             position:AVCaptureDevicePositionUnspecified];
        
        NSArray<AVCaptureDevice *> *devices = discoverySession.devices;
        NSMutableArray<NSDictionary<NSString *, NSObject *> *> *reply =
        [[NSMutableArray alloc] initWithCapacity:devices.count];
        for (AVCaptureDevice *device in devices) {
            NSString *lensFacing;
            switch ([device position]) {
                case AVCaptureDevicePositionBack:
                    lensFacing = @"back";
                    break;
                case AVCaptureDevicePositionFront:
                    lensFacing = @"front";
                    break;
                case AVCaptureDevicePositionUnspecified:
                    lensFacing = @"external";
                    break;
            }
            
            [reply addObject:@{
                @"name" : [device uniqueID],
                @"lensFacing" : lensFacing
            }];
        }
        result(reply);
    }
    result(nil);
}
@end
