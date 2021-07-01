import AVFoundation
import CoreMotion
import Flutter
import Foundation

class ScannerView: NSObject, FlutterTexture, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    // 链接相机用的
    var _captureSession: AVCaptureSession?
    // 获取相机设备
    var _captureDevice: AVCaptureDevice?
    // 视频输入
    var _captureVideoInput: AVCaptureInput?
    // 视频输出
    var _captureOutput: AVCaptureMetadataOutput?
    // 视频输出2
    var _captureVideoOutput: AVCaptureVideoDataOutput?
   
    var _latestPixelBuffer: CVPixelBuffer?
    
    var _previewSize: CGSize?
    
    var _curiosityEvent: CuriosityEvent
    
    var _registrar: FlutterPluginRegistrar
    
    var _result: FlutterResult
    
    var viewId: Int64?
    
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
        _captureSession = AVCaptureSession()
        _captureDevice = AVCaptureDevice(uniqueID: cameraId!!)!
        let queue = DispatchQueue(label: "curiosity.captureQueue")
        do {
            _captureVideoInput = try AVCaptureDeviceInput(device: _captureDevice!)
        } catch {
            result(nil)
            return
        }
        _captureVideoOutput = AVCaptureVideoDataOutput()
        _captureOutput = AVCaptureMetadataOutput()
     
        _captureVideoOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        _captureVideoOutput!.alwaysDiscardsLateVideoFrames = true
        _captureVideoOutput!.setSampleBufferDelegate(self, queue: queue)
//
        let connection = AVCaptureConnection(inputPorts: _captureVideoInput!.ports, output: _captureVideoOutput!)
        
        if _captureDevice!.position == AVCaptureDevice.Position.front {
            connection.isVideoMirrored = true
        }
        _captureSession!.addInput(_captureVideoInput!)
        _captureSession!.addOutput(_captureVideoOutput!)
     
        _captureOutput!.setMetadataObjectsDelegate(self, queue: queue)
        _captureSession!.addOutput(_captureOutput!)
        _captureOutput!.metadataObjectTypes = _captureOutput!.availableMetadataObjectTypes
        // 扫码区域的大小
//        var layer = AVCaptureVideoPreviewLayer(layer: _captureSession)
//        layer.frame = CGRectMake(left, top, size, size)
//        _captureOutput.rectOfInterest
        _captureOutput!.setMetadataObjectsDelegate(self, queue: queue)
        _captureOutput!.metadataObjectTypes = [
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
       
        _captureSession!.addConnection(connection)
        setCaptureSessionPreset(resolutionPreset!!)
        viewId = registrar.textures().register(self)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            let metaObject = metadataObjects[0]
            _curiosityEvent.sendEvent(arguments: ScannerTools.scanDataToMap(data: metaObject as? AVMetadataMachineReadableCodeObject))
        }
    }
 
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if output == _captureVideoOutput {
//            var newBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
//            CFGetRetainCount(newBuffer)
        
//            var old = _latestPixelBuffer
//            while OSAtomicCompareAndSwapPtrBarrier(old!, newBuffer!, &_latestPixelBuffer) {
//                old = _latestPixelBuffer
//            }
            
//            while !OSAtomicCompareAndSwapPtrBarrier(old, newBuffer, (void **) & _latestPixelBuffer) {
//                old = _latestPixelBuffer
//            }
//            if old != nil {
//                CFRelease(old)
//            }
        
            _registrar.textures().textureFrameAvailable(viewId!)
            _result([
                "cameraState": "onOpened",
                "textureId": viewId!,
                "previewWidth": _previewSize!.width,
                "previewHeight": _previewSize!.height,
            ])
            _captureSession!.startRunning()
        }
    }

    // 打开/关闭 闪光灯
    func setFlashMode(status: Bool) {
        try? _captureDevice!.lockForConfiguration()
        var isSuccess = true
        if _captureDevice!.hasFlash {
            if status {
                _captureDevice!.flashMode = AVCaptureDevice.FlashMode.on
                _captureDevice!.torchMode = AVCaptureDevice.TorchMode.on
            } else {
                _captureDevice!.flashMode = AVCaptureDevice.FlashMode.off
                _captureDevice!.torchMode = AVCaptureDevice.TorchMode.off
            }
        } else {
            isSuccess = false
        }
        _captureDevice!.unlockForConfiguration()
        _result(isSuccess)
    }
    
    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
//        var pixelBuffer = _latestPixelBuffer!
//
//        while !OSAtomicCompareAndSwapPtrBarrier(pixelBuffer, nil, &_latestPixelBuffer) {
//            pixelBuffer = _latestPixelBuffer!
//        }
//        return _latestPixelBuffer
        nil
    }
    
    func close() {
        _captureSession!.stopRunning()
        for intput in _captureSession!.inputs {
            _captureSession!.removeInput(intput)
        }
        for output in _captureSession!.outputs {
            _captureSession!.removeOutput(output)
        }
        _registrar.textures().unregisterTexture(viewId!)
        _result(true)
    }
    
    private func setCaptureSessionPreset(_ resolutionPreset: String) {
        switch resolutionPreset {
        case "max":
            if _captureSession!.canSetSessionPreset(AVCaptureSession.Preset.high) {
                _captureSession!.sessionPreset = AVCaptureSession.Preset.high
                let width = _captureDevice!.activeFormat.highResolutionStillImageDimensions.width
                let height = _captureDevice!.activeFormat.highResolutionStillImageDimensions.height
                let widthFloat = CGFloat(Float(bitPattern: UInt32(width)))
                let heightFloat = CGFloat(Float(bitPattern: UInt32(height)))
                _previewSize = CGSize(width: widthFloat, height: heightFloat)
            }
            
        case "ultraHigh":
            if _captureSession!.canSetSessionPreset(AVCaptureSession.Preset.hd4K3840x2160) {
                _captureSession!.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
                _previewSize = CGSize(width: 3840, height: 2160)
            }
        case "veryHigh":
            if _captureSession!.canSetSessionPreset(AVCaptureSession.Preset.hd1920x1080) {
                _captureSession!.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
                _previewSize = CGSize(width: 1920, height: 1080)
            }
        case "high":
            if _captureSession!.canSetSessionPreset(AVCaptureSession.Preset.hd1280x720) {
                _captureSession!.sessionPreset = AVCaptureSession.Preset.hd1280x720
                _previewSize = CGSize(width: 1280, height: 720)
            }
        case "medium":
            if _captureSession!.canSetSessionPreset(AVCaptureSession.Preset.vga640x480) {
                _captureSession!.sessionPreset = AVCaptureSession.Preset.hd1280x720
                _previewSize = CGSize(width: 640, height: 480)
            }
        case "low":
            if _captureSession!.canSetSessionPreset(AVCaptureSession.Preset.cif352x288) {
                _captureSession!.sessionPreset = AVCaptureSession.Preset.cif352x288
                _previewSize = CGSize(width: 320, height: 288)
            }
 
        default: break
        }
    }
}
