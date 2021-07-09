import AVFoundation
import Flutter
import Foundation

class ScannerTools {
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
                            "type": "qrCode",
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
        if #available(iOS 10.0, *) {
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
        return []
    }
    
    static func getScanType(_ arguments: [AnyHashable: Any?]?) -> [AVMetadataObject.ObjectType] {
        var types = [AVMetadataObject.ObjectType]()
        let scanTypes = arguments?["scanTypes"] as? [String]?
        if scanTypes != nil {
            for type in scanTypes!! {
                switch type {
                case "aztec":
                    types.append(.aztec)
                case "upcE":
                    types.append(.upce)
                case "ean13":
                    types.append(.ean13)
                case "ean8":
                    types.append(.ean8)
                case "code39":
                    types.append(.code39)
                case "code93":
                    types.append(.code93)
                case "code128":
                    types.append(.code128)
                case "qrCode":
                    types.append(.qr)
                case "dataMatrix":
                    types.append(.dataMatrix)
                case "pdf417":
                    types.append(.pdf417)
                case "code39Mod43":
                    types.append(.code39Mod43)
                case "itf14":
                    types.append(.itf14)
                case "interleaved2of5":
                    types.append(.interleaved2of5)
                case "dogBody":
                    if #available(iOS 13.0, *) {
                        types.append(.dogBody)
                    }
                case "catBody":
                    if #available(iOS 13.0, *) {
                        types.append(.catBody)
                    }
                case "humanBody":
                    if #available(iOS 13.0, *) {
                        types.append(.humanBody)
                    }
                default:
                    break
                }
            }
        } else {
            types.append(AVMetadataObject.ObjectType.qr)
        }
        return types
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
