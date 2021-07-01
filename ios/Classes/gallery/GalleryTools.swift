import Flutter
import Foundation
import MobileCoreServices

class GalleryTools: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var _controller: UIImagePickerController?
    var _call: FlutterMethodCall
    var _result: FlutterResult

    var _cameraFlashMode: Bool?

    init(call: FlutterMethodCall, result: @escaping FlutterResult) {
        _call = call
        _result = result
        super.init()
    }

    func initPickerController() {
        if _controller == nil {
            _controller = UIImagePickerController()
        }
    }

    // 打开相机
    func openSystemCamera() {
        initPickerController()
        open(sourceType: UIImagePickerController.SourceType.camera)
    }

    // 打开相册
    func openSystemGallery() {
        initPickerController()
        open(sourceType: UIImagePickerController.SourceType.photoLibrary)
    }

    // 打开相簿
    func openSystemAlbum() {
        initPickerController()
        open(sourceType: UIImagePickerController.SourceType.savedPhotosAlbum)
    }

    private func open(sourceType: UIImagePickerController.SourceType) {
        if _controller != nil, UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let data = _call.arguments as? [AnyHashable: Any?]
            let allowsEditing = data!["allowsEditing"] as! Bool?

            _controller!.delegate = self
            _controller!.allowsEditing = allowsEditing ?? false
            _controller!.sourceType = sourceType
            if sourceType == UIImagePickerController.SourceType.camera {
                let flashMode = data!["flashMode"] as! Bool?
                let isFront = data!["isFront"] as! Bool?
                let isSound = data!["isSound"] as! Bool?
                let videoMaximumDuration = data!["videoMaximumDuration"] as! Double?
                let qualityType = data!["qualityType"] as! Int?
                let cameraMode = data!["cameraMode"] as! Int?

                _controller!.videoMaximumDuration = videoMaximumDuration ?? 10.0

                if isFront != nil && isFront! {
                    _controller!.cameraDevice = UIImagePickerController.CameraDevice.front
                } else {
                    _controller!.cameraDevice = UIImagePickerController.CameraDevice.rear
                }

                if cameraMode == 0 {
                    _controller!.cameraCaptureMode = UIImagePickerController.CameraCaptureMode.photo
                } else {
                    _controller!.cameraCaptureMode = UIImagePickerController.CameraCaptureMode.video
                }

                if isSound != nil && isSound! {
                    _controller!.mediaTypes = kUTTypeImage as! [String]
                } else {
                    _controller!.mediaTypes = kUTTypeVideo as! [String]
                }

                if qualityType == 0 {
                    _controller!.videoQuality = UIImagePickerController.QualityType.typeHigh
                } else if qualityType == 1 {
                    _controller!.videoQuality = UIImagePickerController.QualityType.typeMedium
                } else if qualityType == 2 {
                    _controller!.videoQuality = UIImagePickerController.QualityType.typeLow
                } else if qualityType == 3 {
                    _controller!.videoQuality = UIImagePickerController.QualityType.type640x480
                }

                if flashMode == nil {
                    _controller!.cameraFlashMode = UIImagePickerController.CameraFlashMode.auto
                } else if flashMode! {
                    _controller!.cameraFlashMode = UIImagePickerController.CameraFlashMode.on
                } else {
                    _controller!.cameraFlashMode = UIImagePickerController.CameraFlashMode.off
                }
            }

            UIApplication.shared.delegate?.window??.rootViewController?.present(_controller!, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // 相册选择图片
        if _controller?.sourceType == UIImagePickerController.SourceType.photoLibrary {}
        // 相薄选择图片
        if _controller?.sourceType == UIImagePickerController.SourceType.savedPhotosAlbum {}
        // 打开的相机
        if _controller?.sourceType == UIImagePickerController.SourceType.camera {}

        if #available(iOS 11.0, *) {
            _result([
                "imagePath": info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.imageURL.rawValue)],
                "originalImage": info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)]

            ])
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        _controller?.dismiss(animated: true, completion: {
            self._result(nil)
        })
    }

    func saveImageToGallery() {
        let arguments = _call.arguments as! [AnyHashable: Any?]
        let imageBytes = arguments["imageBytes"] as? FlutterStandardTypedData
        let quality = (arguments["quality"] as? Int)
        if imageBytes != nil {
            let image = UIImage(data: imageBytes!.data)
            if let quality = image?.jpegData(compressionQuality: CGFloat(quality! / 100)),
               let imageQuality = UIImage(data: quality)
            {
                UIImageWriteToSavedPhotosAlbum(imageQuality, self, #selector(saveImage), nil)
                return
            }
        }
        _result(false)
    }

    func saveFileToGallery() {
        let path = _call.arguments as? String
        if Tools.isImageFile(path) {
            if let image = UIImage(contentsOfFile: path!) {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImage), nil)
                return
            }
        } else if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path!) {
            UISaveVideoAtPathToSavedPhotosAlbum(path!, self, #selector(saveVideo), nil)
            return
        }
        _result(false)
    }

    @objc private func saveImage(
        image: UIImage?,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeMutableRawPointer?
    ) {
        _result(error == nil)
    }

    @objc private func saveVideo(
        videoPath: String?,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeMutableRawPointer?
    ) {
        _result(error == nil)
    }
}
