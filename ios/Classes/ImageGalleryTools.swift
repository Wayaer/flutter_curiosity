import Flutter
import Photos
import UIKit

public class ImageGalleryTools: NSObject {
    static let shared = ImageGalleryTools()
       
    override private init() {}
    
    var result: FlutterResult?
    
    func saveVideo(_ result: @escaping FlutterResult, _ path: String, isReturnImagePath: Bool) {
        self.result = result
        
        if !isReturnImagePath {
            UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(didFinishSavingVideo(videoPath:error:contextInfo:)), nil)
            return
        }
        var videoIds: [String] = []
        
        PHPhotoLibrary.shared().performChanges({
            let req = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: path))
            if let videoId = req?.placeholderForCreatedAsset?.localIdentifier {
                videoIds.append(videoId)
            }
        }, completionHandler: { [unowned self] success, _ in
            DispatchQueue.main.async {
                if success, videoIds.count > 0 {
                    let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: videoIds, options: nil)
                    if assetResult.count > 0 {
                        let videoAsset = assetResult[0]
                        PHImageManager().requestAVAsset(forVideo: videoAsset, options: nil) { avurlAsset, _, _ in
                            if let urlStr = (avurlAsset as? AVURLAsset)?.url.absoluteString {
                                self.result?(true)
//                                self.saveResult(isSuccess: true, filePath: urlStr)
                            }
                        }
                    }
                } else {
                    self.result?(true)
//                    self.saveResult(isSuccess: false, error: self.errorMessage)
                }
            }
        })
    }
    
    func saveImage(_ result: @escaping FlutterResult, _ image: UIImage, isReturnImagePath: Bool) {
        self.result = result
        if !isReturnImagePath {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(didFinishSavingImage(image:error:contextInfo:)), nil)
            return
        }
        
        var imageIds: [String] = []
        
        PHPhotoLibrary.shared().performChanges({
            let req = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let imageId = req.placeholderForCreatedAsset?.localIdentifier {
                imageIds.append(imageId)
            }
        }, completionHandler: { [unowned self] success, _ in
            DispatchQueue.main.async {
                if success, imageIds.count > 0 {
                    let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: imageIds, options: nil)
                    if assetResult.count > 0 {
                        let imageAsset = assetResult[0]
                        let options = PHContentEditingInputRequestOptions()
                        options.canHandleAdjustmentData = { _
                            -> Bool in true
                        }
                        imageAsset.requestContentEditingInput(with: options) { [unowned self] contentEditingInput, _ in
                            if let urlStr = contentEditingInput?.fullSizeImageURL?.absoluteString {
                                self.result?(true)
//                                self.saveResult(isSuccess: true, filePath: urlStr)
                            }
                        }
                    }
                } else {
                    self.result?(false)
//                    self.saveResult(isSuccess: false, error: self.errorMessage)
                }
            }
        })
    }
    
    func saveImageAtFileUrl(_ url: String, isReturnImagePath: Bool) {
        if !isReturnImagePath {
            if let image = UIImage(contentsOfFile: url) {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(didFinishSavingImage(image:error:contextInfo:)), nil)
            }
            return
        }
        
        var imageIds: [String] = []
        
        PHPhotoLibrary.shared().performChanges({
            let req = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(string: url)!)
            if let imageId = req?.placeholderForCreatedAsset?.localIdentifier {
                imageIds.append(imageId)
            }
        }, completionHandler: { [unowned self] success, _ in
            DispatchQueue.main.async {
                if success, imageIds.count > 0 {
                    let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: imageIds, options: nil)
                    if assetResult.count > 0 {
                        let imageAsset = assetResult[0]
                        let options = PHContentEditingInputRequestOptions()
                        options.canHandleAdjustmentData = { _
                            -> Bool in true
                        }
                        imageAsset.requestContentEditingInput(with: options) { [unowned self] contentEditingInput, _ in
                            if let urlStr = contentEditingInput?.fullSizeImageURL?.absoluteString {
                                self.result?(true)
//                                self.saveResult(isSuccess: true, filePath: urlStr)
                            }
                        }
                    }
                } else {
                    self.result?(false)
//                    self.saveResult(isSuccess: false, error: self.errorMessage)
                }
            }
        })
    }
    
    /// finish saving，if has error，parameters error will not nill
    @objc func didFinishSavingImage(image: UIImage, error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        result?(error == nil)
//        saveResult(isSuccess: error == nil, error: error?.description)
    }
    
    @objc func didFinishSavingVideo(videoPath: String, error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        result?(error == nil)
//        saveResult(isSuccess: error == nil, error: error?.description)
    }
    
    func isImageFile(filename: String) -> Bool {
        return filename.hasSuffix(".jpg")
            || filename.hasSuffix(".png")
            || filename.hasSuffix(".jpeg")
            || filename.hasSuffix(".JPEG")
            || filename.hasSuffix(".JPG")
            || filename.hasSuffix(".PNG")
            || filename.hasSuffix(".gif")
            || filename.hasSuffix(".GIF")
            || filename.hasSuffix(".heic")
            || filename.hasSuffix(".HEIC")
    }
}
