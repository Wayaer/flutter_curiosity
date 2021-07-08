import AVFoundation
import CoreMotion
import Flutter
import Foundation

class ScannerView: NSObject, FlutterTexture, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    // 链接相机用的
    var _captureSession: AVCaptureSession?
    // 获取相机设备
    var _captureDevice: AVCaptureDevice?
    // 视频输出
    var _captureVideoOutput: AVCaptureVideoDataOutput?
    
    var _latestPixelBuffer: CVPixelBuffer?
    
    var _previewSize: CGSize?
    
    var _curiosityEvent: CuriosityEvent
    
    var _registrar: FlutterPluginRegistrar
    
    var _result: FlutterResult
    
    var textureId: Int64?
    
    init(call: FlutterMethodCall, result: @escaping FlutterResult, event: CuriosityEvent, registrar: FlutterPluginRegistrar) {
        _registrar = registrar
        _curiosityEvent = event
        _result = result
        super.init()
        let arguments = call.arguments as? [AnyHashable: Any?]
        let cameraId = arguments?["cameraId"] as? String?
        let resolutionPreset = arguments?["resolutionPreset"] as? String?
        if cameraId == nil || resolutionPreset == nil {
            result(nil)
            return
        }
        
        _captureDevice = AVCaptureDevice(uniqueID: cameraId!!)
        
        // Add device input.
        var videoInput: AVCaptureInput?
        do {
            videoInput = try AVCaptureDeviceInput(device: _captureDevice!)
        } catch {
            result(nil)
            return
        }
        // Add video output.
        _captureVideoOutput = AVCaptureVideoDataOutput()
        _captureVideoOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        _captureVideoOutput!.alwaysDiscardsLateVideoFrames = true
        _captureVideoOutput!.setSampleBufferDelegate(self, queue: .main)
        
        let connection = AVCaptureConnection(inputPorts: videoInput!.ports, output: _captureVideoOutput!)
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }
        
        for connection in _captureVideoOutput!.connections {
            connection.videoOrientation = .portrait
            if _captureDevice!.position == .front, connection.isVideoMirroringSupported {
                connection.isVideoMirrored = true
            }
        }
        
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }
        
        // Add metadata output.
        let captureOutput = AVCaptureMetadataOutput()
        
        _captureSession = AVCaptureSession()
        if _captureSession!.canAddInput(videoInput!) {
            _captureSession!.addInput(videoInput!)
        }
        
        if _captureSession!.canAddOutput(_captureVideoOutput!) {
            _captureSession!.addOutput(_captureVideoOutput!)
        }
        if _captureSession!.canAddOutput(captureOutput) {
            _captureSession!.addOutput(captureOutput)
        }
        
        //        captureOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureOutput.setMetadataObjectsDelegate(self, queue: .main)
        captureOutput.metadataObjectTypes = captureOutput.availableMetadataObjectTypes
        // 扫码区域的大小
        //        var layer = AVCaptureVideoPreviewLayer(layer: _captureSession)
        //        layer.frame = CGRectMake(left, top, size, size)
        //        _captureOutput.rectOfInterest
        captureOutput.metadataObjectTypes = [
            AVMetadataObject.ObjectType.aztec,
            AVMetadataObject.ObjectType.code39,
            AVMetadataObject.ObjectType.code93,
            AVMetadataObject.ObjectType.code128,
            AVMetadataObject.ObjectType.dataMatrix,
            AVMetadataObject.ObjectType.ean8,
            AVMetadataObject.ObjectType.ean13,
            AVMetadataObject.ObjectType.pdf417,
            AVMetadataObject.ObjectType.qr,
            AVMetadataObject.ObjectType.upce,
            AVMetadataObject.ObjectType.code39Mod43,
        ]
        
        if _captureSession!.canAddConnection(connection) {
            _captureSession!.addConnection(connection)
        }
  
        setCaptureSessionPreset(resolutionPreset!!)
        print("相机创建完毕")
        //        return self
    }
    
    func start() {
        print("开始输出视频流")
        textureId = _registrar.textures().register(self)
        _result([
            "cameraState": "onOpened",
            "textureId": textureId!,
            "previewWidth": _previewSize!.width,
            "previewHeight": _previewSize!.height,
        ])
        print("_captureSession?.startRunning()")
        _captureSession?.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        print("解析出来数据")
        if metadataObjects.count > 0 {
            let metaObject = metadataObjects[0]
            _curiosityEvent.sendEvent(arguments: ScannerTools.scanDataToMap(data: metaObject as? AVMetadataMachineReadableCodeObject))
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("输出视频流 captureOutput")
        if output == _captureVideoOutput {
//                        var newBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
//                        CFGetRetainCount(newBuffer)
//
//                        var old = _latestPixelBuffer
//                        while OSAtomicCompareAndSwapPtrBarrier(old!, newBuffer!, &_latestPixelBuffer) {
//                            old = _latestPixelBuffer
//                        }
//
//                        if old != nil {
//                            CFRelease(old)
//                        }
            _latestPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            _registrar.textures().textureFrameAvailable(textureId!)
        }
    }
    
    // 打开/关闭 闪光灯
    func setFlashMode(status: Bool) {
        try? _captureDevice!.lockForConfiguration()
        var isSuccess = true
        if _captureDevice!.hasFlash {
            if status {
                _captureDevice!.flashMode = .on
                _captureDevice!.torchMode = .on
            } else {
                _captureDevice!.flashMode = .off
                _captureDevice!.torchMode = .off
            }
        } else {
            isSuccess = false
        }
        _captureDevice!.unlockForConfiguration()
        _result(isSuccess)
    }
    
    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
//        print("copyPixelBuffer")
        //        var pixelBuffer = _latestPixelBuffer!
        //
        //        while !OSAtomicCompareAndSwapPtrBarrier(pixelBuffer, nil, &_latestPixelBuffer) {
        //            pixelBuffer = _latestPixelBuffer!
        //        }
        //        return _latestPixelBuffer
        if _latestPixelBuffer == nil {
            return nil
        }
        return Unmanaged<CVPixelBuffer>.passRetained(_latestPixelBuffer!)
    }
    
    func close() {
        _captureSession!.stopRunning()
        for intput in _captureSession!.inputs {
            _captureSession!.removeInput(intput)
        }
        for output in _captureSession!.outputs {
            _captureSession!.removeOutput(output)
        }
        _registrar.textures().unregisterTexture(textureId!)
        _result(true)
    }
    
    private func setCaptureSessionPreset(_ resolutionPreset: String) {
        switch resolutionPreset {
        case "max":
            if _captureSession!.canSetSessionPreset(.high) {
                _captureSession!.sessionPreset = .high
                let width = _captureDevice!.activeFormat.highResolutionStillImageDimensions.width
                let height = _captureDevice!.activeFormat.highResolutionStillImageDimensions.height
                let widthFloat = CGFloat(Float(bitPattern: UInt32(width)))
                let heightFloat = CGFloat(Float(bitPattern: UInt32(height)))
                _previewSize = CGSize(width: widthFloat, height: heightFloat)
            }
            
        case "ultraHigh":
            if _captureSession!.canSetSessionPreset(.hd4K3840x2160) {
                _captureSession!.sessionPreset = .hd4K3840x2160
                _previewSize = CGSize(width: 3840, height: 2160)
            }
        case "veryHigh":
            if _captureSession!.canSetSessionPreset(.hd1920x1080) {
                _captureSession!.sessionPreset = .hd4K3840x2160
                _previewSize = CGSize(width: 1920, height: 1080)
            }
        case "high":
            if _captureSession!.canSetSessionPreset(.hd1280x720) {
                _captureSession!.sessionPreset = .hd1280x720
                _previewSize = CGSize(width: 1280, height: 720)
            }
        case "medium":
            if _captureSession!.canSetSessionPreset(.vga640x480) {
                _captureSession!.sessionPreset = .hd1280x720
                _previewSize = CGSize(width: 640, height: 480)
            }
        case "low":
            if _captureSession!.canSetSessionPreset(.cif352x288) {
                _captureSession!.sessionPreset = .cif352x288
                _previewSize = CGSize(width: 320, height: 288)
            }
        default: break
        }
    }
}
