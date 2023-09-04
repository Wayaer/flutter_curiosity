import Flutter
import Foundation
import MobileCoreServices
import Photos

class GalleryTools: FlutterAppDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var controller: UIImagePickerController?
    var call: FlutterMethodCall
    var result: FlutterResult

    init(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        self.call = call
        self.result = result
        super.init()
    }

    func initPickerController() {
        if controller == nil {
            controller = UIImagePickerController()
            controller!.delegate = self
        }
    }

    // 打开相机
    func openSystemCamera() {
        initPickerController()
        controller?.sourceType = UIImagePickerController.SourceType.camera
        open()
    }

    // 打开相册
    func openSystemGallery() {
        initPickerController()
        controller?.sourceType = UIImagePickerController.SourceType.photoLibrary
        open()
    }

    // 打开相簿
    func openSystemAlbum() {
        initPickerController()
        controller?.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
        open()
    }

    private func open() {
        if controller != nil, UIImagePickerController.isSourceTypeAvailable(controller!.sourceType) {
            let data = call.arguments as? [AnyHashable: Any?]
            let allowsEditing = data!["allowsEditing"] as! Bool?
            controller!.allowsEditing = allowsEditing ?? false
            if controller!.sourceType == UIImagePickerController.SourceType.camera {
                let flashMode = data!["flashMode"] as! Int?
                let isFront = data!["isFront"] as! Bool?
                let hasSound = data!["hasSound"] as! Bool?
                let videoMaximumDuration = data!["videoMaximumDuration"] as! Double?
                let qualityType = data!["qualityType"] as! Int?
                let cameraMode = data!["cameraMode"] as! Int?

                controller!.videoMaximumDuration = videoMaximumDuration ?? 10.0

                if isFront != nil {
                    controller!.cameraDevice = UIImagePickerController.CameraDevice(rawValue: isFront! ? 1 : 0)!
                }
                if cameraMode == 0 {
                    controller!.mediaTypes = [String(kUTTypeImage), String(kUTTypeVideo)]
                } else {
                    if hasSound != nil, hasSound! {
                        controller!.mediaTypes = [String(kUTTypeVideo)]
                    } else {
                        controller!.mediaTypes = [String(kUTTypeMovie)]
                    }
                }
                controller!.cameraCaptureMode = UIImagePickerController.CameraCaptureMode(rawValue: cameraMode!)!

                controller!.videoQuality = UIImagePickerController.QualityType(rawValue: qualityType!)!
                controller!.cameraFlashMode = UIImagePickerController.CameraFlashMode(rawValue: flashMode!)!
            }
            UIApplication.shared.delegate?.window??.rootViewController?.present(controller!, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        controller!.dismiss(animated: true, completion: { [self] in
            if controller!.sourceType == UIImagePickerController.SourceType.photoLibrary {
                if #available(iOS 11.0, *) {
                    let url = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.imageURL.rawValue)] as? NSURL
                    result(url?.path)
                    controller = nil
                    return
                }
            }

            if controller!.sourceType == UIImagePickerController.SourceType.camera {
                let image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as! UIImage
                var localId: String?

                PHPhotoLibrary.shared().performChanges {
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    localId = assetChangeRequest.placeholderForCreatedAsset?.localIdentifier

                } completionHandler: { _, _ in
                    let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: [localId!], options: nil)
                    assetResult.firstObject?.requestContentEditingInput(with: nil, completionHandler: { [self] content, _ in
                        result(content?.fullSizeImageURL?.path)
                        controller = nil
                    })
                }
                return
            }
            if controller!.sourceType == UIImagePickerController.SourceType.savedPhotosAlbum {
                if #available(iOS 11.0, *) {
                    let url = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.imageURL.rawValue)] as? NSURL
                    result(url?.path)
                    controller = nil
                    return
                }
            }
            result(nil)
            controller = nil
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        controller?.dismiss(animated: true, completion: { [self] in
            result(nil)
            controller = nil
        })
    }

    @objc private func saveImage(
        image: UIImage?,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeMutableRawPointer?
    ) {
        result(error == nil)
    }

    @objc private func saveVideo(
        videoPath: String?,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeMutableRawPointer?
    ) {
        result(error == nil)
    }
}
