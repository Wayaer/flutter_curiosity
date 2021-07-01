import Flutter

public class CuriosityPlugin: NSObject, FlutterPlugin {
    var curiosityChannel: FlutterMethodChannel
    var curiosityEvent: CuriosityEvent?

    var registrar: FlutterPluginRegistrar
    var keyboardStatus = false
    var call: FlutterMethodCall?
    var result: FlutterResult?
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

    public func handle(_ _call: FlutterMethodCall, result _result: @escaping FlutterResult) {
        call = _call
        result = _result
        print("CuriosityHandle")
        print(call?.method)
        switch call!.method {
        case "exitApp":
            exit(0)
        case "startCuriosityEvent":
            if curiosityEvent != nil {
                result!(true)
                return
            }
            curiosityEvent = CuriosityEvent(messenger: registrar.messenger())
            result!(false)
        case "stopCuriosityEvent":
            if curiosityEvent != nil {
                curiosityEvent!.dispose()
            }
            result!(true)
        case "getAppInfo":
            result!(NativeTools.getAppInfo)
        case "getDeviceInfo":
            result!(NativeTools.getDeviceInfo)
        case "getGPSStatus":
            result!(NativeTools.getGPSStatus)
        case "openSystemSetting":
            result!(NativeTools.openSystemSetting)
        case "openSystemGallery":
            initGalleryTools()
            gallery?.openSystemGallery()
        case "openSystemCamera":
            initGalleryTools()
            gallery?.openSystemCamera()
        case "openSystemAlbum":
            initGalleryTools()
            gallery?.openSystemAlbum()
        case "saveFileToGallery":
            initGalleryTools()
            gallery?.saveFileToGallery()
        case "saveImageToGallery":
            initGalleryTools()
            gallery?.saveImageToGallery()
        case "scanImageByte":
            result!(ScannerTools.scanImageByte(call: call!))
        case "availableCameras":
            result!(ScannerTools.availableCameras())
        case "initializeCameras":
            if scanner == nil, curiosityEvent != nil {
                scanner = ScannerView(call: call!, result: result!, event: curiosityEvent!, registrar: registrar)
                return
            }
            result!(nil)
        case "setFlashMode":
            if scanner == nil {
                result!(false)
                return
            }
            scanner!.setFlashMode(status: call!.arguments as! Bool)
        case "disposeCameras":
            if scanner == nil {
                result!(false)
                return
            }
            scanner!.close()
        default:
            print("FlutterMethodNotImplemented")
            result!("FlutterMethodNotImplemented")
        }
    }

    func initGalleryTools() {
        if gallery == nil {
            gallery = GalleryTools(call: call!, result: result!)
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
