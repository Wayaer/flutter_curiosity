import Flutter
import UIKit

public class ImageGalleryTools: NSObject {
    static let shared = ImageGalleryTools()

    override private init() {}

    var result: FlutterResult?

    public static func saveBytesImageToGallery(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: Any]
        let bytes = (arguments["bytes"] as! FlutterStandardTypedData).data
        var sourceImage = UIImage(data: bytes)
        let quality = arguments["quality"] as! Int

        var isJPEG = false
        if quality < 100 {
            let newImage = sourceImage!.jpegData(compressionQuality: CGFloat(quality / 100))
            if newImage != nil {
                let newUIImage = UIImage(data: newImage!)
                if newUIImage != nil {
                    sourceImage = newUIImage
                    isJPEG = true
                }
            }
        }
        let sourceExtension = arguments["extension"] as! String
        switch sourceExtension {
        case "jpeg":
            if !isJPEG, let jpedData = sourceImage?.jpegData(compressionQuality: CGFloat(1)) {
                sourceImage = UIImage(data: jpedData)
            }
        case "png":
            if let pngData = sourceImage?.pngData() {
                sourceImage = UIImage(data: pngData)
            }
        default:
            result(false)
            return
        }

        if sourceImage != nil {
            ImageGalleryTools.shared.saveImage(sourceImage!, result)
        } else {
            result(false)
        }
    }

    public static func saveFilePathToGallery(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: Any]
        let sourcePath = arguments["path"] as! String
        let sourceExtension = arguments["extension"] as! String
        let fileType = getFileType(sourceExtension)
        switch fileType {
        case .image:
            let sourceImage = UIImage(contentsOfFile: sourcePath)
            if sourceImage != nil {
                ImageGalleryTools.shared.saveImage(sourceImage!, result)
            } else {
                result(false)
            }

        case .video:
            ImageGalleryTools.shared.saveVideo(sourcePath, result)

        case .none:
            result(false)
        }
    }

    func saveImage(_ image: UIImage, _ result: @escaping FlutterResult) {
        self.result = result
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(didFinishSavingImage(image:error:contextInfo:)), nil)
    }

    func saveVideo(_ path: String, _ result: @escaping FlutterResult) {
        self.result = result
        UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(didFinishSavingVideo(videoPath:error:contextInfo:)), nil)
    }

    @objc func didFinishSavingImage(image: UIImage, error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        result?(error == nil)
    }

    @objc func didFinishSavingVideo(videoPath: String, error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        result?(error == nil)
    }

    // 支持的图片扩展名
    private static let imageExtensions: Set<String> = [
        "jpg", "jpeg", "png", "gif", "bmp", "webp", "heif", "heic",
        "svg", "tiff", "raw", "ico"
    ]

    // 支持的视频扩展名
    private static let videoExtensions: Set<String> = [
        "mp4", "mov", "avi", "flv", "wmv", "mkv", "webm", "mpeg",
        "mpg", "3gp", "m4v", "rmvb", "ts", "mts"
    ]

    private static func getFileType(_ fileExtension: String) -> FileType? {
        if imageExtensions.contains(fileExtension.lowercased()) {
            return .image
        } else if videoExtensions.contains(fileExtension.lowercased()) {
            return .video
        } else {
            return nil
        }
    }
}

private enum FileType {
    case image
    case video
}
