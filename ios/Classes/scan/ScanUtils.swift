import Foundation
import AVFoundation
import Flutter
class ScanUtils {
    //本地图片识别
    public func scanImagePath(call: FlutterMethodCall, result: FlutterResult) {
        let path = call.arguments("path")
        if (path is NSNull) {
            result(nil)
            return
        }
        //加载文件
        let fh = FileHandle(forReadingAtPath: path ?? "")
        let data = fh?.readDataToEndOfFile()
        result(self.getCode(data))
    }
    //图片urls识别
    public  func scanImageUrl(call: FlutterMethodCall, result: FlutterResult) {
        let url = call.arguments(forKey: "url")
        let nsUrl = URL(string: url ?? "")
        var data: Data? = nil
        do {
            if let nsUrl = nsUrl {
                data = try NSURLConnection.sendSynchronousRequest(URLRequest(url: nsUrl), returning: nil)
            }
        } catch {
        }
        result(self.getCode(data))
    }
    //内存图片识别
    public func scanImageMemory(call: FlutterMethodCall, result: FlutterResult) {
        let uint8list = call.arguments.value(forKey: "uint8list") as? FlutterStandardTypedData
        result(self.getCode(uint8list?.data))
    }
    //获取二维码数据
    public  func getCode(data: Data) -> [AnyHashable : Any] {
        if data != nil {
            var detectImage: CIImage? = nil
            if let data = data {
                detectImage = CIImage(data: data)
            }
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [
                CIDetectorAccuracy: CIDetectorAccuracyHigh
            ])
            var feature: [CIFeature]? = nil
            if let detectImage = detectImage {
                feature = detector?.features(in: detectImage, options: nil)
            }
            if feature?.count == 0 {
                return nil
            } else {
                for index in 0..<(feature?.count ?? 0) {
                    let qrCode = feature?[index] as? CIQRCodeFeature
                    let resultStr = qrCode?.messageString
                    if resultStr != nil {
                        var dict: [AnyHashable : Any] = [:]
                        dict["code"] = resultStr
                        dict["type"] = AVMetadataObject.ObjectType.qr
                        return dict
                    }
                }
            }
        }
        return nil
    }
    
    //二维码数据转换
    public func scanDataToMap(data: AVMetadataMachineReadableCodeObject) -> [AnyHashable : Any] {
        if data == nil {
            return nil
        }
        var result: [AnyHashable : Any] = [:]
        result["code"] = data?.stringValue
        result["type"] = data?.type
        return result
    }
    
}
