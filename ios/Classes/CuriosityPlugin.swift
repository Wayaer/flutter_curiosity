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
            exit(0)
        case "getGPSStatus":
            // 判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
            result(CLLocationManager.locationServicesEnabled())
        case "saveBytesImageToGallery":
            let arguments = call.arguments as! [String: Any]
            let bytes = (arguments["bytes"] as! FlutterStandardTypedData).data
            var image = UIImage(data: bytes)
            let quality = arguments["quality"] as? Int
            if image != nil, quality != nil {
                let newImage = image!.jpegData(compressionQuality: CGFloat(quality! / 100))
                if newImage != nil {
                    let newUIImage = UIImage(data: newImage!)
                    if newUIImage != nil {
                        image = newUIImage
                    }
                }
            }
            if image != nil {
                ImageGalleryTools.shared.saveImage(result, image!)
            } else {
                result(false)
            }
   
        case "addKeyboardListener":
            notificationCenter.addObserver(self, selector: #selector(didShow), name: UIResponder.keyboardDidShowNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(didShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(didHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(didHide), name: UIResponder.keyboardDidHideNotification, object: nil)
            result(true)
        case "removeKeyboardListener":
            notificationCenter.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
            notificationCenter.removeObserver(self,  name: UIResponder.keyboardWillShowNotification, object: nil)
            notificationCenter.removeObserver(self,  name: UIResponder.keyboardWillHideNotification, object: nil)
            notificationCenter.removeObserver(self,  name: UIResponder.keyboardDidHideNotification, object: nil)
            result(true)
        case "saveFilePathToGallery":
            let arguments = call.arguments as! [String: Any]
            let path = arguments["filePath"] as! String
            if ImageGalleryTools.shared.isImageFile(filename: path) {
                ImageGalleryTools.shared.saveImageAtFileUrl(result, path)
            } else {
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
                    ImageGalleryTools.shared.saveVideo(result, path)
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

    @objc func didShow(_ notification: Notification) {
       let rect = getKeyboardHeight(notification)
        channel.invokeMethod("onKeyboardStatus", arguments: [
            "visibility":true,
            "width":rect.width,
            "height":rect.height,
         
        ])
    }
    
    func getKeyboardHeight(_ notification: Notification) ->CGRect{
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            return keyboardFrame
        }
        return CGRect()
    }
    
    @objc func didHide(_ notification: Notification) {
        let rect = getKeyboardHeight(notification)
        channel.invokeMethod("onKeyboardStatus", arguments: [
            "visibility":false,
            "width":rect.width,
            "height":rect.height,
        ])
    }

}
