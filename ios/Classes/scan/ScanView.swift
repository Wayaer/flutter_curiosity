import AVFoundation
import Flutter


class ScanView: UIView,AVCaptureMetadataOutputObjectsDelegate {
    private let scanEvent = ScanEventStreamHandler()
    private var session: AVCaptureSession
    private var methodChannel: FlutterMethodChannel
    private var captureLayer: AVCaptureVideoPreviewLayer
    private var device: AVCaptureDevice
    
    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger: (NSObjectProtocol & FlutterBinaryMessenger)?) {
        let methodchannelName = String(format: "scanView/%lld/method", viewId)
        let eventChannelName = String(format: "scanView/%lld/event", viewId)
        let eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger:binaryMessenger!)
        methodChannel = FlutterMethodChannel(name: methodchannelName, binaryMessenger: binaryMessenger!)
        eventChannel.setStreamHandler((scanEvent as! FlutterStreamHandler & NSObjectProtocol))
        
//        weak var weakSelf = self
//        weakSelf.channel.methodCallHandler = { call, result in
//            weakSelf.on(call, result: result)
//        }

        captureLayer = AVCaptureVideoPreviewLayer(session: session)
        captureLayer.backgroundColor = UIColor.black.cgColor
        captureLayer.addSublayer(captureLayer)
        captureLayer.videoGravity = .resizeAspectFill
        captureLayer.backgroundColor = UIColor.black.cgColor
        device = AVCaptureDevice.default(for: .video)!
        var input: AVCaptureDeviceInput? = nil
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch {
        }
        let output = AVCaptureMetadataOutput()
        if let input = input {
            session.addInput(input)
        }
        session.addOutput(output)
        session.sessionPreset = .high
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.aztec, .code39,.code93, .code128,.dataMatrix,.ean8,.ean13,.itf14,.pdf417,.qr,.upce]
        startScan()
//        return self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        captureLayer.frame = bounds
    }
    
    
     func handle( call: FlutterMethodCall, result: FlutterResult) {
        if (call.method == "startScan") {
            startScan()
            result(nil)
        } else if (call.method == "stopScan") {
            pause()
            result(nil)
        } else if (call.method == "setFlashMode") {
            let status = (call.arguments as AnyObject).value(forKey: "status") as? NSNumber
            result(NSNumber(value: status?.boolValue ?? false))
        } else if (call.method == "getFlashMode") {
            result(NSNumber(value: getFlashMode()))
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    func startScan() {
        if !session.isRunning {
            session.startRunning()
        }
    }
    
    func stopScan() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func setFlashMode( status: Bool) -> Bool {
        do {
            try device.lockForConfiguration()
        } catch {
        }
        var isSuccess = true
        if device.hasFlash {
            if status {
                device.flashMode = .on
                device.torchMode = .on
            } else {
                device.flashMode = .off
                device.torchMode = .off
            }
        } else {
            isSuccess = false
        }
        device.unlockForConfiguration()
        
        return isSuccess
        
    }
    
    func getFlashMode() -> Bool {
        do {
            try device.lockForConfiguration()
        } catch {
        }
        let isSuccess = device.flashMode == .on && device.torchMode == .on
        device.unlockForConfiguration()
        return isSuccess
        
    }
    func captureOutput(output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            let data = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
            let value = data?.stringValue
            if (value?.count ?? 0) != 0  {
                scanEvent.sendEvent(event: ScanUtils.scanDataToMap(data))
            
            }
        }
    }
    //    func onCancelWithArguments(arguments: Any?) -> FlutterError? {
    //        if scanView {
    //            scanView.pause()
    //        }
    //        return nil
    //    }
    //
    //    func getResult(msg: [AnyHashable : Any]?) {
    //        if events {
    //            events(msg)
    //        }
    //    }
    
}

import Foundation
class ScanEventStreamHandler: FlutterStreamHandler {
    private var eventSink:FlutterEventSink? = nil
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    //发送event
    public func sendEvent(event:Any) {
        eventSink?(event)
    }
}


//class ScanViewEventChannel : NSObject<FlutterStreamHandler> {
//    private var eventSink: FlutterEventSink
//
//
//    override func onListenWithArguments( arguments: Any, events: FlutterEventSink) -> FlutterError? {
//        eventSink = events
//        if ScanView {
//            let isScan = (arguments as? NSObject)?.value(forKey: "isScan") as? NSNumber
//            if isScan != nil {
//                if isScan?.boolValue ?? false {
//                    ScanView.resume()
//                } else {
//                    ScanView.pause()
//                }
//            }
//        }
//        return nil
//    }
//
//    func onCancelWithArguments(arguments: Any) -> FlutterError? {
//        if ScanView {
//            ScanView.pause()
//        }
//        return nil
//    }
//
//    func getResult(msg: [AnyHashable : Any]) {
//        if eventSink {
//            eventSink(msg)
//        }
//    }
//}
