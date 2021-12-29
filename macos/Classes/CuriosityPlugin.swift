import FlutterMacOS
import SwiftUI

public class CuriosityPlugin: NSObject, FlutterPlugin {
    var channel: FlutterMethodChannel
    var methodCall: CuriosityMethodCall

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "Curiosity", binaryMessenger: registrar.messenger)
        let plugin = CuriosityPlugin(registrar, channel)
        registrar.addMethodCallDelegate(plugin, channel: channel)
    }

    init(_ registrar: FlutterPluginRegistrar, _ _channel: FlutterMethodChannel) {
        channel = _channel
        methodCall = CuriosityMethodCall(registrar, _channel)
        super.init()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        methodCall.handle(call: call, result: result)
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        methodCall.event?.dispose()
        channel.setMethodCallHandler(nil)
    }
}
