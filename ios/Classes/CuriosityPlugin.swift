import Flutter

class CuriosityPlugin: NSObject, FlutterPlugin {
    var curiosityChannel: FlutterMethodChannel
    var curiosityEvent: CuriosityEvent?

    var registrar: FlutterPluginRegistrar
    var keyboardStatus = false
    var call: FlutterMethodCall?
    var result: FlutterResult?
    var gallery: GalleryTools?
    var scanner: ScannerView?

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "Curiosity", binaryMessenger: registrar.messenger())
        let plugin = CuriosityPlugin(registrar, channel)
        registrar.addApplicationDelegate(plugin)
    }

    init(_ _registrar: FlutterPluginRegistrar, _ _channel: FlutterMethodChannel) {
        curiosityChannel = _channel
        registrar = _registrar
        super.init()
        let center = NotificationCenter.default
        center.addObserver(self, selector: Selector(("didShow")), name: UIResponder.keyboardDidShowNotification, object: nil)
        center.addObserver(self, selector: Selector(("didShow")), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: Selector(("didHide")), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func handle(_call: FlutterMethodCall, _result: @escaping FlutterResult) {
        call = _call
        result = _result
        switch call!.method {
        case "exitApp":
            exit(0)
        case "startCuriosityEvent":
            if curiosityEvent == nil {
                curiosityEvent = CuriosityEvent(messenger: registrar.messenger())
            }
            result!(true)
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
            result!(false)
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
            result!(FlutterMethodNotImplemented)
        }
    }

    func initGalleryTools() {
        if gallery == nil {
            gallery = GalleryTools(call: call!, result: result!)
        }
    }

    func didShow() {
        if !keyboardStatus {
            keyboardStatus = true
            curiosityChannel.invokeMethod("keyboardStatus", arguments: keyboardStatus)
        }
    }

    func didHide() {
        if keyboardStatus {
            keyboardStatus = false
            curiosityChannel.invokeMethod("keyboardStatus", arguments: keyboardStatus)
        }
    }
}
