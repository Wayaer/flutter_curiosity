import Flutter

class CuriosityMethodCall: NSObject {
    public var event: CuriosityEvent?

    var channel: FlutterMethodChannel?

    var messenger: FlutterBinaryMessenger

    var keyboardStatus = false

    var gallery: GalleryTools?

    public init(_ _messenger: FlutterBinaryMessenger, _ _channel: FlutterMethodChannel) {
        messenger = _messenger
        channel = _channel
        super.init()
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(didShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        center.addObserver(self, selector: #selector(didShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(didHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    open func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "exitApp":
            exit(0)
        case "startCuriosityEvent":
            if event == nil {
                event = CuriosityEvent(messenger)
            }
            result(event != nil)
        case "sendCuriosityEvent":
            event?.sendEvent(arguments: call.arguments)
            result(event != nil)
        case "stopCuriosityEvent":
            disposeEvent()
            result(event == nil)
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
        case "saveFileToGallery":
            initGalleryTools(call, result)
            gallery?.saveFileToGallery()
        case "saveImageToGallery":
            initGalleryTools(call, result)
            gallery?.saveImageToGallery()
        default:
            result(FlutterMethodNotImplemented)
        }
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
            channel?.invokeMethod("keyboardStatus", arguments: keyboardStatus)
        }
    }

    @objc func didHide() {
        if keyboardStatus {
            keyboardStatus = false
            channel?.invokeMethod("keyboardStatus", arguments: keyboardStatus)
        }
    }

    private func disposeEvent() {
        if event != nil {
            event!.dispose()
            event = nil
        }
    }
}
