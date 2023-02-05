import FlutterMacOS

class CuriosityMethodCall: NSObject {
    public var event: CuriosityEvent?

    public var _channel: FlutterMethodChannel

    public var _registrar: FlutterPluginRegistrar

    public var _webview: WebViewTools?

    public init(_ registrar: FlutterPluginRegistrar, _ channel: FlutterMethodChannel) {
        _registrar = registrar
        _channel = channel
        super.init()
    }

    public func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "exitApp":
            exit(0)
        case "startCuriosityEvent":
            if event == nil {
                event = CuriosityEvent(_registrar.messenger)
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
        case "getWindowSize":
            result(DesktopTools.getWindowSize())
        case "setWindowSize":
            result(DesktopTools.setWindowSize(call))
        case "setMinWindowSize":
            result(DesktopTools.setMinWindowSize(call))
        case "setMaxWindowSize":
            result(DesktopTools.setMaxWindowSize(call))
        case "resetMaxWindowSize":
            result(DesktopTools.resetMaxWindowSize())
        case "toggleFullScreen":
            result(DesktopTools.toggleFullScreen())
        case "setFullScreen":
            result(DesktopTools.setFullScreen(call))
        case "getFullScreen":
            result(DesktopTools.getFullScreen())
        case "toggleBorders":
            result(DesktopTools.toggleBorders())
        case "setBorders":
            result(DesktopTools.setBorders(call))
        case "hasBorders":
            result(DesktopTools.hasBorders())
        case "focus":
            NSApplication.shared.activate(ignoringOtherApps: true)
            result(true)
        case "stayOnTop":
            result(DesktopTools.stayOnTop(call))
        case "openSystemSetting":
            result(Tools.openUrl(call.arguments as! String))
        case "openWebView":
            if _webview == nil {
                _webview = WebViewTools(_channel, _registrar)
            }
            _webview!.openWebview(call, result)

        case "closeWebView":
            _webview?.closeWebView()
            result(_webview != nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func disposeEvent() {
        if event != nil {
            event!.dispose()
            event = nil
        }
    }
}
