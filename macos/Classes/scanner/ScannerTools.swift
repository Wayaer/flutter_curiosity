import AVFoundation
import FlutterMacOS
import Foundation

@available(macOS 10.15, *)
enum ScannerTools {
    // 识别图片中的二维码
    static func scanImageByte(_ uint8list: FlutterStandardTypedData?) -> [AnyHashable: Any?]? {
        if uint8list != nil {
            let detectImage = CIImage(data: uint8list!.data)
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
        return nil
    }

    static func availableCameras() -> [[AnyHashable: Any?]] {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)

        let devices = discoverySession.devices
        var reply: [[AnyHashable: Any?]] = []
        for device in devices {
            var lensFacing: String?
            switch device.position {
            case .back:
                lensFacing = "back"
            case .front:
                lensFacing = "front"
            case .unspecified:
                lensFacing = "external"
            default: break
            }
            reply.append([
                "name": device.uniqueID,
                "lensFacing": lensFacing
            ])
        }
        return reply
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
