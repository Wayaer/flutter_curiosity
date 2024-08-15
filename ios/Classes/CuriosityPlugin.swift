import CoreLocation
import Flutter

public class CuriosityPlugin: NSObject, FlutterPlugin {
    var channel: FlutterMethodChannel

    var keyboardStatus = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "Curiosity", binaryMessenger: registrar.messenger())
        let plugin = CuriosityPlugin(channel)
        registrar.addMethodCallDelegate(plugin, channel: channel)
    }

    init(_ channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(didShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        center.addObserver(self, selector: #selector(didShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(didHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "exitApp":
            exit(0)
        case "getPackageInfo":
            result(getPackageInfo())
        case "getGPSStatus":
            result(getGPSStatus())
        case "saveImageToGallery":
            let arguments = call.arguments as! [String: Any]
            let bytes = (arguments["bytes"] as! FlutterStandardTypedData).data
            let image = UIImage(data: bytes)
            if image != nil {
                let quality = arguments["quality"] as! Int
                let isReturnImagePath = arguments["isReturnImagePathOfIOS"] as! Bool
                let newImage = image!.jpegData(compressionQuality: CGFloat(quality / 100))!
                ImageGalleryTools.shared.saveImage(result, UIImage(data: newImage) ?? image!, isReturnImagePath: isReturnImagePath)
            } else {
                result(false)
            }
        case "saveFileToGallery":
            let arguments = call.arguments as! [String: Any]
            let path = arguments["filePath"] as! String
            let isReturnFilePath = arguments["isReturnPathOfIOS"] as! Bool
            if ImageGalleryTools.shared.isImageFile(filename: path) {
                ImageGalleryTools.shared.saveImageAtFileUrl(path, isReturnImagePath: isReturnFilePath)
            } else {
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
                    ImageGalleryTools.shared.saveVideo(result, path, isReturnImagePath: isReturnFilePath)
                } else {
                    result(false)
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        channel.setMethodCallHandler(nil)
    }

    @objc func didShow() {
        if !keyboardStatus {
            keyboardStatus = true
            channel.invokeMethod("keyboardStatus", arguments: keyboardStatus)
        }
    }

    @objc func didHide() {
        if keyboardStatus {
            keyboardStatus = false
            channel.invokeMethod("keyboardStatus", arguments: keyboardStatus)
        }
    }

    func getPackageInfo() -> [AnyHashable: Any?]? {
        let appInfo = Bundle.main.infoDictionary
        return [
            "version": appInfo?["CFBundleShortVersionString"],
            "buildNumber": appInfo?["CFBundleVersion"] as! String,
            "packageName": appInfo?["CFBundleIdentifier"],
            "appName": appInfo?["CFBundleName"],
            "sdkBuild": appInfo?["DTSDKBuild"],
            "platformName": appInfo?["DTPlatformName"],
            "minimumOSVersion": appInfo?["MinimumOSVersion"],
            "platformVersion": appInfo?["DTPlatformVersion"],
        ]
    }

    // 判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
    func getGPSStatus() -> Bool {
        CLLocationManager.locationServicesEnabled()
    }
}
