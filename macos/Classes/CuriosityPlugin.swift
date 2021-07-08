import FlutterMacOS
import SwiftUI

public class CuriosityPlugin: NSObject, FlutterPlugin {
    var curiosityChannel: FlutterMethodChannel?
    var curiosityEvent: CuriosityEvent?

    var registrar: FlutterPluginRegistrar

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "Curiosity", binaryMessenger: registrar.messenger)
        let plugin = CuriosityPlugin(registrar, channel)
        registrar.addMethodCallDelegate(plugin, channel: channel)
    }

    init(_ _registrar: FlutterPluginRegistrar, _ _channel: FlutterMethodChannel) {
        curiosityChannel = _channel
        registrar = _registrar
        super.init()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "exitApp":
            exit(0)
        case "startCuriosityEvent":
            if curiosityEvent == nil {
                curiosityEvent = CuriosityEvent(registrar.messenger)
            }
            result(curiosityEvent != nil)
        case "sendCuriosityEvent":
            curiosityEvent?.sendEvent(arguments: call.arguments)
            result(curiosityEvent != nil)
        case "stopCuriosityEvent":
            disposeEvent()
            result(curiosityEvent == nil)
        case "getAppInfo":
            result(NativeTools.getAppInfo())
        case "getAppPath":
            result(NativeTools.getAppPath())
        case "getDeviceInfo":
            result(NativeTools.getDeviceInfo())
        case "getGPSStatus":
            result(NativeTools.getGPSStatus())

//        case "openSystemGallery":
//            initGalleryTools(call, result)
//            gallery?.openSystemGallery()
//        case "openSystemCamera":
//            initGalleryTools(call, result)
//            gallery?.openSystemCamera()
//        case "openSystemAlbum":
//            initGalleryTools(call, result)
//            gallery?.openSystemAlbum()

        case "scanImageByte":
            if #available(macOS 10.15, *) { let arguments = call.arguments as! [AnyHashable: Any?]
                let useEvent = arguments["useEvent"] as! Bool?
                let uint8list = arguments["byte"] as! FlutterStandardTypedData?

                let code = ScannerTools.scanImageByte(uint8list)

                if useEvent != nil, useEvent! {
                    curiosityEvent?.sendEvent(arguments: code)
                    return
                }
                result(code)
            }
            result(nil)
        case "availableCameras":
            if #available(macOS 10.15, *) {
                result(ScannerTools.availableCameras())
            } else {
                result(nil)
            }
        case "getWindowSize":
            let window = NSApplication.shared.mainWindow
            let width = window?.frame.size.width
            let height = window?.frame.size.height
            result([width, height])
        case "setWindowSize":
            let window = NSApplication.shared.mainWindow
            if window != nil, let width: Float = (call.arguments as? [String: Any])?["width"] as? Float,
               let height: Float = (call.arguments as? [String: Any])?["height"] as? Float
            {
                var rect = window!.frame
                rect.origin.y += (rect.size.height - CGFloat(height))
                rect.size.width = CGFloat(width)
                rect.size.height = CGFloat(height)
                window!.setFrame(rect, display: true)
            }
            result(true)
        case "setMinWindowSize":
            let window = NSApplication.shared.mainWindow
            if window != nil, let width: Float = (call.arguments as? [String: Any])?["width"] as? Float,
               let height: Float = (call.arguments as? [String: Any])?["height"] as? Float
            {
                window!.minSize = CGSize(width: CGFloat(width), height: CGFloat(height))
            }
            result(true)
        case "setMaxWindowSize":
            let window = NSApplication.shared.mainWindow
            if window != nil, let width: Float = (call.arguments as? [String: Any])?["width"] as? Float,
               let height: Float = (call.arguments as? [String: Any])?["height"] as? Float
            {
                if width == 0 || height == 0 {
                    window!.maxSize = CGSize(
                        width: CGFloat(Float.greatestFiniteMagnitude),
                        height: CGFloat(Float.greatestFiniteMagnitude))
                } else {
                    window?.maxSize = CGSize(width: CGFloat(width), height: CGFloat(height))
                }
            }
            result(true)

        case "resetMaxWindowSize":
            let window = NSApplication.shared.mainWindow
            if window != nil {
                window!.maxSize = CGSize(
                    width: CGFloat(Float.greatestFiniteMagnitude),
                    height: CGFloat(Float.greatestFiniteMagnitude))
            }
            result(true)

        case "toggleFullScreen":
            let window = NSApplication.shared.mainWindow
            if window != nil { window!.toggleFullScreen(nil) }
            result(true)
        case "setFullScreen":
            let window = NSApplication.shared.mainWindow
            if window != nil, let bFullScreen: Bool = (call.arguments as? [String: Any])?["fullscreen"] as? Bool {
                if bFullScreen {
                    if !window!.styleMask.contains(.fullScreen) {
                        window!.toggleFullScreen(nil)
                    }
                } else {
                    if window!.styleMask.contains(.fullScreen) {
                        window!.toggleFullScreen(nil)
                    }
                }
                result(true)
                return
            }
            result(false)
        case "getFullScreen":
            let window = NSApplication.shared.mainWindow
            result(window?.styleMask.contains(.fullScreen))
        case "toggleBorders":
            let window = NSApplication.shared.mainWindow
            if window != nil {
                if window!.styleMask.contains(.borderless) {
                    window!.styleMask.remove(.borderless)
                } else {
                    window!.styleMask.insert(.borderless)
                }
            }
            result(true)
        case "setBorders":
            let window = NSApplication.shared.mainWindow
            if window != nil, let bBorders: Bool = (call.arguments as? [String: Any])?["borders"] as? Bool {
                if window!.styleMask.contains(.borderless) == bBorders {
                    if bBorders {
                        window!.styleMask.remove(.borderless)
                    } else {
                        window!.styleMask.insert(.borderless)
                    }
                }
                result(true)
                return
            }
            result(false)
        case "hasBorders":
            let window = NSApplication.shared.mainWindow
            result(!(window?.styleMask.contains(.borderless) ?? false))
        case "focus":
            NSApplication.shared.activate(ignoringOtherApps: true)
            result(true)
        case "stayOnTop":
            let window = NSApplication.shared.mainWindow
            if window != nil, let bstayOnTop: Bool = (call.arguments as? [String: Any])?["stayOnTop"] as? Bool {
                window!.level = bstayOnTop ? .floating : .normal
            }
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        curiosityChannel?.setMethodCallHandler(nil)
        curiosityChannel = nil
        disposeEvent()
    }

    private func disposeEvent() {
        if curiosityEvent != nil {
            curiosityEvent!.dispose()
            curiosityEvent = nil
        }
    }
}
