import CoreLocation
import Flutter

public class CuriosityPlugin: NSObject, FlutterPlugin {
    var channel: FlutterMethodChannel

    let notificationCenter = NotificationCenter.default

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "Curiosity", binaryMessenger: registrar.messenger())
        let plugin = CuriosityPlugin(channel)
        registrar.addMethodCallDelegate(plugin, channel: channel)
    }

    init(_ channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "exitApp":
            result(true)
            exit(0)
        case "getGPSStatus":
            // 判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
            result(CLLocationManager.locationServicesEnabled())
        case "addKeyboardListener":
            notificationCenter.addObserver(self, selector: #selector(didShow), name: UIResponder.keyboardDidShowNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(didShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(didHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(didHide), name: UIResponder.keyboardDidHideNotification, object: nil)
            result(true)
        case "removeKeyboardListener":
            notificationCenter.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
            notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            notificationCenter.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
            result(true)
        case "saveBytesImageToGallery":
            ImageGalleryTools.saveBytesImageToGallery(call, result)
        case "saveFilePathToGallery":
            ImageGalleryTools.saveFilePathToGallery(call, result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        channel.setMethodCallHandler(nil)
    }

    @objc func didShow(_ notification: Notification) {
        let rect = getKeyboardHeight(notification)
        channel.invokeMethod("onKeyboardStatus", arguments: [
            "visibility": true,
            "width": rect.width,
            "height": rect.height,
        ])
    }

    func getKeyboardHeight(_ notification: Notification) -> CGRect {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        {
            return keyboardFrame
        }
        return CGRect()
    }

    @objc func didHide(_ notification: Notification) {
        let rect = getKeyboardHeight(notification)
        channel.invokeMethod("onKeyboardStatus", arguments: [
            "visibility": false,
            "width": rect.width,
            "height": rect.height,
        ])
    }
}
