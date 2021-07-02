import Flutter

public class CuriosityPlugin: NSObject, FlutterPlugin {
    var curiosityChannel: FlutterMethodChannel
    var curiosityEvent: CuriosityEvent?

    var registrar: FlutterPluginRegistrar
    var keyboardStatus = false

    var gallery: GalleryTools?
    var scanner: ScannerView?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "Curiosity", binaryMessenger: registrar.messenger())
        let plugin = CuriosityPlugin(registrar, channel)
        registrar.addMethodCallDelegate(plugin, channel: channel)
    }

    init(_ _registrar: FlutterPluginRegistrar, _ _channel: FlutterMethodChannel) {
        curiosityChannel = _channel
        registrar = _registrar
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
        case "startCuriosityEvent":
            if curiosityEvent != nil {
                result(true)
                return
            }
            curiosityEvent = CuriosityEvent(messenger: registrar.messenger())
            result(false)
        case "stopCuriosityEvent":
            if curiosityEvent != nil {
                curiosityEvent!.dispose()
            }
            result(true)
        case "getAppInfo":
            result(NativeTools.getAppInfo())
        case "getAppPath":
            result(NativeTools.getAppPath())
        case "getDeviceInfo":
            result(NativeTools.getDeviceInfo())
        case "getGPSStatus":
            result(NativeTools.getGPSStatus())
        case "openSystemSetting":
            result(NativeTools.openSystemSetting())
        case "openSystemGallery":
            initGalleryTools(call, result)
            gallery?.openSystemGallery()
        case "openSystemCamera":
            initGalleryTools(call, result)
            gallery?.openSystemCamera()
        case "openSystemAlbum":
            initGalleryTools(call, result)
            gallery?.openSystemAlbum()
        case "saveFileToGallery":
            initGalleryTools(call, result)
            gallery?.saveFileToGallery()
        case "saveImageToGallery":
            initGalleryTools(call, result)
            gallery?.saveImageToGallery()
        case "scanImageByte":

            let arguments = call.arguments as! [AnyHashable: Any?]
            let useEvent = arguments["useEvent"] as! Bool?
            let uint8list = arguments["byte"] as! FlutterStandardTypedData?
            let code = ScannerTools.scanImageByte(uint8list)
            if useEvent != nil, useEvent! {
                curiosityEvent?.sendEvent(arguments: code)
                return
            }
            result(code)
        case "availableCameras":
            result(ScannerTools.availableCameras())
        case "initializeCameras":
            if scanner == nil, curiosityEvent != nil {
                scanner = ScannerView(call: call, result: result, event: curiosityEvent!, registrar: registrar)
                return
            }
            result(nil)
        case "setFlashMode":
            if scanner == nil {
                result(false)
                return
            }
            scanner!.setFlashMode(status: call.arguments as! Bool)
        case "disposeCameras":
            if scanner == nil {
                result(false)
                return
            }
            scanner!.close()
        default:
            print("FlutterMethodNotImplemented")
            result("FlutterMethodNotImplemented")
        }
    }

    func initGalleryTools(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if gallery == nil {
            gallery = GalleryTools(call: call, result: result)
        }
    }

    @objc func didShow() {
        if !keyboardStatus {
            keyboardStatus = true
            curiosityChannel.invokeMethod("keyboardStatus", arguments: keyboardStatus)
        }
    }

    @objc func didHide() {
        if keyboardStatus {
            keyboardStatus = false
            curiosityChannel.invokeMethod("keyboardStatus", arguments: keyboardStatus)
        }
    }
}
