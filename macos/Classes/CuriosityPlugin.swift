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
