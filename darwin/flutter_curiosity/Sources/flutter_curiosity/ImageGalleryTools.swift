#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import AppKit
import FlutterMacOS
#endif

public class ImageGalleryTools: NSObject {
#if os(iOS)
    static let shared = ImageGalleryTools()

    override private init() {}

    var result: FlutterResult?

    public static func saveBytesImageToGallery(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard hasPhotoLibraryUsageDescription else {
            result(false)
            return
        }
        guard let arguments = call.arguments as? [String: Any],
              let typedData = arguments["bytes"] as? FlutterStandardTypedData,
              let originalImage = UIImage(data: typedData.data) else {
            result(false)
            return
        }
        let quality = arguments["quality"] as? Int ?? 100
        let sourceExtension = arguments["extension"] as? String ?? "jpeg"

        var sourceImage = originalImage
        if sourceExtension == "jpeg",
           quality < 100,
           let compressedData = originalImage.jpegData(compressionQuality: CGFloat(quality) / 100.0),
           let compressedImage = UIImage(data: compressedData) {
            sourceImage = compressedImage
        }

        switch sourceExtension {
        case "jpeg":
            if let jpegData = sourceImage.jpegData(compressionQuality: 1.0),
               let jpegImage = UIImage(data: jpegData) {
                sourceImage = jpegImage
            }
        case "png":
            if let pngData = sourceImage.pngData(),
               let pngImage = UIImage(data: pngData) {
                sourceImage = pngImage
            }
        default:
            result(false)
            return
        }

        ImageGalleryTools.shared.saveImage(sourceImage, result)
    }

    public static func saveFilePathToGallery(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard hasPhotoLibraryUsageDescription else {
            result(false)
            return
        }
        guard let arguments = call.arguments as? [String: Any],
              let sourcePath = arguments["path"] as? String,
              let sourceExtension = arguments["extension"] as? String else {
            result(false)
            return
        }
        switch getFileType(sourceExtension) {
        case .image:
            guard let sourceImage = UIImage(contentsOfFile: sourcePath) else {
                result(false)
                return
            }
            ImageGalleryTools.shared.saveImage(sourceImage, result)
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
#elseif os(macOS)
    public static func saveBytesImageToGallery(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let typedData = arguments["bytes"] as? FlutterStandardTypedData,
              let image = NSImage(data: typedData.data) else {
            result(false)
            return
        }
        let quality = arguments["quality"] as? Int ?? 100
        let sourceExtension = arguments["extension"] as? String ?? "jpeg"
        guard let data = encodeImage(image, extension: sourceExtension, quality: quality) else {
            result(false)
            return
        }
        let fileName = makeFileName(arguments["name"] as? String, extension: sourceExtension)
        result(saveData(data, fileName: fileName, directory: .picturesDirectory))
    }

    public static func saveFilePathToGallery(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let sourcePath = arguments["path"] as? String,
              let sourceExtension = arguments["extension"] as? String else {
            result(false)
            return
        }
        guard FileManager.default.fileExists(atPath: sourcePath) else {
            result(false)
            return
        }
        let fileName = makeFileName(arguments["name"] as? String, extension: sourceExtension)
        switch getFileType(sourceExtension) {
        case .image:
            result(copyFile(URL(fileURLWithPath: sourcePath), fileName: fileName, directory: .picturesDirectory))
        case .video:
            result(copyFile(URL(fileURLWithPath: sourcePath), fileName: fileName, directory: .moviesDirectory))
        case .none:
            result(false)
        }
    }

    private static func encodeImage(_ image: NSImage, extension sourceExtension: String, quality: Int) -> Data? {
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff) else {
            return nil
        }
        switch sourceExtension {
        case "jpeg":
            let compression = CGFloat(max(1, min(100, quality))) / 100.0
            return bitmap.representation(using: .jpeg, properties: [.compressionFactor: compression])
        case "png":
            return bitmap.representation(using: .png, properties: [:])
        default:
            return nil
        }
    }

    private static func makeFileName(_ name: String?, extension sourceExtension: String) -> String {
        let rawName = name ?? String(Int(Date().timeIntervalSince1970 * 1000))
        var baseName = (rawName as NSString).lastPathComponent
        baseName = baseName.replacingOccurrences(of: "/", with: "_")
        baseName = baseName.replacingOccurrences(of: ":", with: "_")
        baseName = baseName.trimmingCharacters(in: .whitespacesAndNewlines)
        let suffix = ".\(sourceExtension)"
        if baseName.lowercased().hasSuffix(suffix.lowercased()) {
            baseName = String(baseName.dropLast(suffix.count))
        }
        if baseName.isEmpty {
            baseName = String(Int(Date().timeIntervalSince1970 * 1000))
        }
        return "\(baseName)\(suffix)"
    }

    private static func saveData(
        _ data: Data,
        fileName: String,
        directory: FileManager.SearchPathDirectory
    ) -> Bool {
        guard let folder = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return false
        }
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try data.write(to: uniqueURL(in: folder, fileName: fileName), options: .atomic)
            return true
        } catch {
            return false
        }
    }

    private static func copyFile(
        _ source: URL,
        fileName: String,
        directory: FileManager.SearchPathDirectory
    ) -> Bool {
        guard let folder = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return false
        }
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try FileManager.default.copyItem(at: source, to: uniqueURL(in: folder, fileName: fileName))
            return true
        } catch {
            return false
        }
    }

    private static func uniqueURL(in folder: URL, fileName: String) -> URL {
        let name = fileName as NSString
        let baseName = name.deletingPathExtension
        let fileExtension = name.pathExtension
        var candidate = folder.appendingPathComponent(fileName)
        var index = 1
        while FileManager.default.fileExists(atPath: candidate.path) {
            let suffix = fileExtension.isEmpty ? "\(baseName) (\(index))" : "\(baseName) (\(index)).\(fileExtension)"
            candidate = folder.appendingPathComponent(suffix)
            index += 1
        }
        return candidate
    }
#endif
}

extension ImageGalleryTools {
    static var hasPhotoLibraryUsageDescription: Bool {
        Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryAddUsageDescription") != nil
    }

    // 支持的图片扩展名
    static let imageExtensions: Set<String> = [
        "jpg", "jpeg", "png", "gif", "bmp", "webp", "heif", "heic",
        "svg", "tiff", "raw", "ico"
    ]

    // 支持的视频扩展名
    static let videoExtensions: Set<String> = [
        "mp4", "mov", "avi", "flv", "wmv", "mkv", "webm", "mpeg",
        "mpg", "3gp", "m4v", "rmvb", "ts", "mts"
    ]

    fileprivate static func getFileType(_ fileExtension: String) -> FileType? {
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
