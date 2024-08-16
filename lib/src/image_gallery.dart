part of '../flutter_curiosity.dart';

enum ImageGalleryExtension { jpeg, png }

class ImageGalleryTools {
  /// save image to Gallery
  /// [extension] 保存扩展名 仅支持android  默认JPG
  /// [name]  保存文件名 仅支持android  默认时间戳
  static Future<bool> saveBytesImage(Uint8List bytes,
      {int? quality,
      String? name,
      ImageGalleryExtension extension = ImageGalleryExtension.jpeg}) async {
    if (!Curiosity.isMobile) return false;
    final result =
        await _channel.invokeMethod<bool>('saveBytesImageToGallery', {
      'bytes': bytes,
      'quality': quality,
      'extension': extension.name.toUpperCase(),
      'name': name
    });
    return result == true;
  }

  /// Save the PNG，JPG，JPEG image or video located at [path] to the local device media gallery.
  /// [name]  保存文件名 仅支持android  默认时间戳
  static Future<bool> saveFilePath(String filePath, {String? name}) async {
    if (!Curiosity.isMobile) return false;
    final result = await _channel.invokeMethod<bool>(
        'saveFilePathToGallery', {'filePath': filePath, 'name': name});
    return result == true;
  }
}
