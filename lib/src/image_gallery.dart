part of '../flutter_curiosity.dart';

/// Image extensions supported when saving to the gallery.
enum ImageGalleryExtension { jpeg, png }

/// Tools for saving images and videos.
///
/// On mobile the media is saved to the system photo library, on macOS, Windows
/// and Linux it is saved to the Pictures or Videos folder, and on web the bytes
/// are downloaded by the browser.
class ImageGalleryTools {
  /// Saves [bytes] to the platform destination described above.
  ///
  /// [quality] is clamped to the range 1-100. It is applied on Android, iOS,
  /// HarmonyOS and macOS only.
  /// [name] is the file name. It is used on Android, macOS, Windows and Linux.
  /// Defaults to a timestamp.
  /// [extension] is the file extension. Defaults to [ImageGalleryExtension.jpeg].
  static Future<bool> saveBytesImage(
    Uint8List bytes, {
    int quality = 100,
    String? name,
    ImageGalleryExtension extension = ImageGalleryExtension.jpeg,
  }) async {
    final int safeQuality = quality.clamp(1, 100).toInt();
    final String fileName = name ?? '${DateTime.now().millisecondsSinceEpoch}';
    if (Curiosity.isWeb) {
      return WebPlatform.saveBytesImage(bytes, fileName, extension.name);
    }
    if (Curiosity.isWindows || Curiosity.isLinux) {
      return IoPlatform.saveBytesImage(bytes, fileName, extension.name);
    }
    if (!Curiosity.isMobile && !Curiosity.isMacOS) return false;
    final bool result =
        await _channel.invokeMethod<bool>('saveBytesImageToGallery', <String, dynamic>{
          'bytes': bytes,
          'quality': safeQuality,
          'extension': extension.name,
          'name': fileName,
        }) ??
        false;
    return result;
  }

  /// Saves the image or video located at [path] to the system gallery, or to
  /// the Pictures or Videos folder on macOS, Windows and Linux.
  ///
  /// [name] is the file name. It is used on Android, macOS, Windows and Linux.
  /// Defaults to the file name of [path].
  /// Returns `false` when the platform is web or [path] or its extension is invalid.
  static Future<bool> saveFilePath(String path, {String? name}) async {
    if (Curiosity.isWeb || path.isEmpty) return false;
    final String fileName = name ?? _fileNameOf(path);
    final int dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == fileName.length - 1) return false;
    final String extension = fileName.substring(dotIndex + 1).toLowerCase();
    final String baseName = fileName.substring(0, dotIndex);
    if (Curiosity.isWindows || Curiosity.isLinux) {
      return IoPlatform.saveFilePath(path, baseName, extension);
    }
    if (!Curiosity.isMobile && !Curiosity.isMacOS) return false;
    final bool result =
        await _channel.invokeMethod<bool>('saveFilePathToGallery', <String, dynamic>{
          'path': path,
          'name': baseName,
          'extension': extension,
        }) ??
        false;
    return result;
  }

  /// Returns the file name part of [path].
  static String _fileNameOf(String path) {
    final int slashIndex = path.lastIndexOf(RegExp(r'[/\\]'));
    return slashIndex < 0 ? path : path.substring(slashIndex + 1);
  }
}
