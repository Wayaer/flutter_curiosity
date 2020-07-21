#import "Scanner.h"
#import "ScannerTools.h"
typedef enum {
    VeryLow,
    Low,
    Medium,
    High,
    VeryHigh,
    UltraHigh,
    Max,
} ResolutionPreset;

@implementation ScannerTools
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
+(NSDictionary *) nativeCode:(NSData *)data{
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



+ (void)setCaptureSessionPreset:(NSString *)resolutionPreset :(AVCaptureSession*)captureSession :(AVCaptureDevice*)captureDevice  :(CGSize)previewSize {
    
    if ([@"Max" isEqualToString:resolutionPreset]) {
        if ([captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            captureSession.sessionPreset = AVCaptureSessionPresetHigh;
            previewSize =
            CGSizeMake(captureDevice.activeFormat.highResolutionStillImageDimensions.width,
                       captureDevice.activeFormat.highResolutionStillImageDimensions.height);
        }
    }else if ([@"UltraHigh" isEqualToString:resolutionPreset]) {
        if (@available(iOS 9.0, *)) {
            if ([captureSession canSetSessionPreset:AVCaptureSessionPreset3840x2160]) {
                captureSession.sessionPreset = AVCaptureSessionPreset3840x2160;
                previewSize = CGSizeMake(3840, 2160);
            }
        } else {
            // Fallback on earlier versions
        }
    }else if ([@"VeryHigh" isEqualToString:resolutionPreset]) {
        if ([captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
            previewSize = CGSizeMake(1920, 1080);
            
        }
    }else if ([@"High" isEqualToString:resolutionPreset]) {
        if ([captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
            previewSize = CGSizeMake(1280, 720);
        }
    }else if ([@"Medium" isEqualToString:resolutionPreset]) {
        if ([captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
            captureSession.sessionPreset = AVCaptureSessionPreset640x480;
            previewSize = CGSizeMake(640, 480);
            
        }
    }else  if ([@"Low" isEqualToString:resolutionPreset]) {
        if ([captureSession canSetSessionPreset:AVCaptureSessionPreset352x288]) {
            captureSession.sessionPreset = AVCaptureSessionPreset352x288;
            previewSize = CGSizeMake(352, 288);
        }
    }else{
        if ([captureSession canSetSessionPreset:AVCaptureSessionPresetLow]) {
            captureSession.sessionPreset = AVCaptureSessionPresetLow;
            previewSize = CGSizeMake(352, 288);
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
