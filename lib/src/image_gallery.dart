part of '../flutter_curiosity.dart';

enum ImageGalleryExtension { jpeg, png }

class ImageGalleryTools {
  /// save image to Gallery
  /// [extension] 保存扩展名 仅支持android  默认JPG
  /// [name]  保存文件名 仅支持android  默认时间戳
  static Future<bool> saveBytesImage(Uint8List bytes,
      {int quality = 100,
      String? name,
      ImageGalleryExtension extension = ImageGalleryExtension.jpeg}) async {
    if (!Curiosity.isMobile) return false;
    if (quality < 1) quality = 1;
    if (quality > 100) quality = 100;
    name ??= '${DateTime.now().millisecondsSinceEpoch}';
    final result =
        await _channel.invokeMethod<bool>('saveBytesImageToGallery', {
      'bytes': bytes,
      'quality': quality,
      'extension': extension.name.toLowerCase(),
      'name': name
    });
    return result == true;
  }

  /// Save the PNG，JPG，JPEG image or video located at [path] to the local device media gallery.
  /// [name]  保存文件名 仅支持android  默认时间戳
  static Future<bool> saveFilePath(String path, {String? name}) async {
    if (!Curiosity.isMobile || path.isEmpty) return false;
    if (name == null) {
      if (path.contains('/')) {
        name = path.split('/').last;
      } else {
        name = path;
      }
    }
    if (!name.contains('.')) return false;
    final extension = name.split('.').last;
    name = name.replaceAll('.$extension', '');
    final result = await _channel.invokeMethod<bool>('saveFilePathToGallery',
        {'path': path, 'name': name, 'extension': extension.toLowerCase()});
    return result == true;
  }
}
