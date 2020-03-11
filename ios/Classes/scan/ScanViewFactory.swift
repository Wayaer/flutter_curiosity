import AVFoundation
import Flutter

class ScanViewFactory: NSObject<FlutterPlatformViewFactory> {
    private var scanView = "scanView"
    
    private weak var messenger: (NSObjectProtocol & FlutterBinaryMessenger)?
    
    
    override init(messenger: (NSObjectProtocol & FlutterBinaryMessenger)?) {
        super.init()
        self.messenger = messenger
    }
    
    
    override func createArgsCodec() -> (NSObjectProtocol & FlutterMessageCodec)? {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    override func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> (NSObjectProtocol & FlutterPlatformView)? {
        let scanView = ScanPlatformView(frame: frame, viewindentifier: viewId, arguments: args, binaryMessenger: messenger)
        return scanView
        
    }
}

class ScanPlatformView: NSObject<FlutterPlatformView> {

    override init(withMessenger frame: CGRect, viewindentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: (NSObjectProtocol & FlutterBinaryMessenger)) {
        super.init()
        let view = ScanView(frame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: messenger)
        view.backgroundColor = UIColor.clear
        view.frame = frame
    }
}
