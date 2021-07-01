import AVFoundation
import Flutter
import Foundation

class ScannerTools {
    // 识别图片中的二维码
    static func scanImageByte(call: FlutterMethodCall) -> [AnyHashable: Any?]? {
        let byte = call.arguments as! [AnyHashable: Any?]
        let uint8list = byte["byte"] as! FlutterStandardTypedData?

        if uint8list != nil {
            return getScanCode(data: uint8list!.data as Data)
        }
        return nil
    }

    // 获取二维码 数据 返回map
    static func getScanCode(data: Data) -> [AnyHashable: Any?]? {
        let detectImage = CIImage(data: data)
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        if detectImage != nil {
            let feature = detector?.features(in: detectImage!, options: nil)
            if feature != nil, feature!.count > 0 {
                for item in feature! {
                    let qrCode = item as! CIQRCodeFeature
                    return [
                        "type": AVMetadataObject.ObjectType.qr,
                        "code": qrCode.messageString
                    ]
                }
            }
        }
        return nil
    }

    static func availableCameras() -> [AnyHashable: Any?]? {
        if #available(iOS 10.0, *) {
            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)

            let devices = discoverySession.devices
            var reply: [[AnyHashable: Any?]] = []
            for device in devices {
                var lensFacing: String?
                switch device.position {
                case AVCaptureDevice.Position.back:
                    lensFacing = "back"
                case AVCaptureDevice.Position.front:
                    lensFacing = "front"
                case AVCaptureDevice.Position.unspecified:
                    lensFacing = "external"
                default: break
                }
                reply.append([
                    "name": device.uniqueID,
                    "lensFacing": lensFacing
                ])
            }
        }
        return nil
    }

    // 转换map
    static func scanDataToMap(data: AVMetadataMachineReadableCodeObject?) -> [AnyHashable: Any?]? {
        if data != nil {
            return [
                "code": data?.stringValue,
                "type": data?.type
            ]
        }

        return nil
    }
}
