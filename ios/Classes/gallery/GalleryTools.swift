import Flutter
import Foundation
import MobileCoreServices
import Photos

class GalleryTools: FlutterAppDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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
                let flashMode = data!["flashMode"] as! Int?
                let isFront = data!["isFront"] as! Bool?
                let hasSound = data!["hasSound"] as! Bool?
                let videoMaximumDuration = data!["videoMaximumDuration"] as! Double?
                let qualityType = data!["qualityType"] as! Int?
                let cameraMode = data!["cameraMode"] as! Int?

                _controller!.videoMaximumDuration = videoMaximumDuration ?? 10.0

                if isFront != nil {
                    _controller!.cameraDevice = UIImagePickerController.CameraDevice(rawValue: isFront! ? 1 : 0)!
                }
                if cameraMode == 0 {
                    _controller!.mediaTypes = [String(kUTTypeImage), String(kUTTypeVideo)]
                } else {
                    if hasSound != nil && hasSound! {
                        _controller!.mediaTypes = [String(kUTTypeVideo)]
                    } else {
                        _controller!.mediaTypes = [String(kUTTypeMovie)]
                    }
                }
                _controller!.cameraCaptureMode = UIImagePickerController.CameraCaptureMode(rawValue: cameraMode!)!

                _controller!.videoQuality = UIImagePickerController.QualityType(rawValue: qualityType!)!
                _controller!.cameraFlashMode = UIImagePickerController.CameraFlashMode(rawValue: flashMode!)!
            }

            UIApplication.shared.delegate?.window??.rootViewController?.present(_controller!, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        _controller?.dismiss(animated: true, completion: { [self] in
            if _controller?.sourceType == UIImagePickerController.SourceType.photoLibrary {
                if #available(iOS 11.0, *) {
                    let url = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.imageURL.rawValue)] as? NSURL
                    _result(url?.absoluteString)
                    return
                }
            }

            if _controller?.sourceType == UIImagePickerController.SourceType.camera {
                let image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as! UIImage
                var localId: String?

                PHPhotoLibrary.shared().performChanges {
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    localId = assetChangeRequest.placeholderForCreatedAsset?.localIdentifier

                } completionHandler: { _, _ in
                    let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: [localId!], options: nil)
                    assetResult.firstObject?.requestContentEditingInput(with: nil, completionHandler: { content, _ in
                        self._result(content?.fullSizeImageURL?.absoluteString)
                    })
                }
                return
            }
            if _controller?.sourceType == UIImagePickerController.SourceType.savedPhotosAlbum {
                if #available(iOS 11.0, *) {
                    let url = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.imageURL.rawValue)] as? NSURL
                    _result(url?.absoluteString)
                    return
                }
            }
            self._result(nil)
        })
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
