import Flutter
import Foundation

class CuriosityEvent: NSObject, FlutterStreamHandler {
    var eventSink: FlutterEventSink?
    var eventChannel: FlutterEventChannel?
    
    init(messenger: FlutterBinaryMessenger) {
        super.init()
        print("已经初始化了CuriosityEvent")
        eventChannel = FlutterEventChannel(name: "curiosity/event", binaryMessenger: messenger)
        eventChannel?.setStreamHandler(self)
    }
    
    internal func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    func sendEvent(arguments: Any?) {
        eventSink?(arguments)
    }
    
    func dispose() {
        eventSink = nil
        eventChannel?.setStreamHandler(nil)
        eventChannel = nil
    }
    
    internal func onCancel(withArguments arguments: Any?) -> FlutterError? {
        dispose()
        return nil
    }
}
