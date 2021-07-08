import FlutterMacOS
import Foundation

class CuriosityEvent: NSObject, FlutterStreamHandler {
    var eventSink: FlutterEventSink?
    var eventChannel: FlutterEventChannel?
  
    init(_ messenger: FlutterBinaryMessenger) {
        super.init()
        eventChannel = FlutterEventChannel(name: "curiosity/event", binaryMessenger: messenger)
        eventChannel!.setStreamHandler(self)
    }
    
    func sendEvent(arguments: Any?) {
        let mainQueue = DispatchQueue.main
        mainQueue.async {
            self.eventSink?(arguments)
        }
    }
    
    func dispose() {
        eventSink = nil
        if eventChannel != nil {
            eventChannel?.setStreamHandler(nil)
            eventChannel = nil
        }
    }

    internal func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    internal func onCancel(withArguments arguments: Any?) -> FlutterError? {
        dispose()
        return nil
    }
}
