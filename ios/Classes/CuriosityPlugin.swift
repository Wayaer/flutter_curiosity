import Flutter

public class CuriosityPlugin: NSObject, FlutterPlugin {
    var channel: FlutterMethodChannel

    var keyboardStatus = false

    var gallery: GalleryTools?

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
        case "getAppInfo":
            result(NativeTools.getAppInfo())
        case "getAppPath":
            result(NativeTools.getAppPath())
        case "getDeviceInfo":
            result(NativeTools.getDeviceInfo())
        case "getGPSStatus":
            result(NativeTools.getGPSStatus())
        case "openSystemSetting":
            NativeTools.openSystemSetting(result)
        case "openSystemGallery":
            initGalleryTools(call, result)
            gallery?.openSystemGallery()
        case "openSystemCamera":
            initGalleryTools(call, result)
            gallery?.openSystemCamera()
        case "openSystemAlbum":
            initGalleryTools(call, result)
            gallery?.openSystemAlbum()
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        channel.setMethodCallHandler(nil)
    }

    func initGalleryTools(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if gallery != nil {
            gallery = nil
        }
        gallery = GalleryTools(call: call, result: result)
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
}
