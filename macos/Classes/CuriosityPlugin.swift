import FlutterMacOS
import SwiftUI

public class CuriosityPlugin: NSObject, FlutterPlugin {
    var channel: FlutterMethodChannel

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "Curiosity", binaryMessenger: registrar.messenger)
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
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        channel.setMethodCallHandler(nil)
    }
}
