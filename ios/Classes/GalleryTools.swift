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
            _controller!.delegate = self
        }
    }

    // 打开相机
    func openSystemCamera() {
        initPickerController()
        _controller?.sourceType = UIImagePickerController.SourceType.camera
        open()
    }

    // 打开相册
    func openSystemGallery() {
        initPickerController()
        _controller?.sourceType = UIImagePickerController.SourceType.photoLibrary
        open()
    }

    // 打开相簿
    func openSystemAlbum() {
        initPickerController()
        _controller?.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
        open()
    }

    private func open() {
        if _controller != nil, UIImagePickerController.isSourceTypeAvailable(_controller!.sourceType) {
            let data = _call.arguments as? [AnyHashable: Any?]
            let allowsEditing = data!["allowsEditing"] as! Bool?

            _controller!.allowsEditing = allowsEditing ?? false

            if _controller!.sourceType == UIImagePickerController.SourceType.camera {
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
        _controller!.dismiss(animated: true, completion: { [self] in
            if _controller!.sourceType == UIImagePickerController.SourceType.photoLibrary {
                if #available(iOS 11.0, *) {
                    let url = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.imageURL.rawValue)] as? NSURL
                    _result(url?.path)
                    _controller = nil
                    return
                }
            }

            if _controller!.sourceType == UIImagePickerController.SourceType.camera {
                let image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as! UIImage
                var localId: String?

                PHPhotoLibrary.shared().performChanges {
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    localId = assetChangeRequest.placeholderForCreatedAsset?.localIdentifier

                } completionHandler: { _, _ in
                    let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: [localId!], options: nil)
                    assetResult.firstObject?.requestContentEditingInput(with: nil, completionHandler: { [self] content, _ in
                        _result(content?.fullSizeImageURL?.path)
                        _controller = nil
                    })
                }
                return
            }
            if _controller!.sourceType == UIImagePickerController.SourceType.savedPhotosAlbum {
                if #available(iOS 11.0, *) {
                    let url = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.imageURL.rawValue)] as? NSURL
                    _result(url?.path)
                    _controller = nil
                    return
                }
            }
            _result(nil)
            _controller = nil
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        _controller?.dismiss(animated: true, completion: { [self] in
            _result(nil)
            _controller = nil
        })
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
