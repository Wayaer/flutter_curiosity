part of '../flutter_curiosity.dart';

class ImageGallery {
  static const MethodChannel _channel = MethodChannel('image_gallery');

  /// save image to Gallery
  static Future<bool> saveImage(Uint8List bytes,
      {int quality = 80,
      String? name,
      bool isReturnImagePathOfIOS = false}) async {
    if (!Curiosity.isMobile) return false;
    final result = await _channel.invokeMethod<bool>('saveImageToGallery', {
      'bytes': bytes,
      'quality': quality,
      'name': name,
      'isReturnImagePathOfIOS': isReturnImagePathOfIOS
    });
    return result == true;
  }

  /// Save the PNG，JPG，JPEG image or video located at [path] to the local device media gallery.
  static Future<bool> saveFile(String filePath,
      {String? name, bool isReturnPathOfIOS = false}) async {
    if (!Curiosity.isMobile) return false;
    final result = await _channel.invokeMethod<bool>('saveFileToGallery', {
      'filePath': filePath,
      'name': name,
      'isReturnPathOfIOS': isReturnPathOfIOS
    });
    return result == true;
  }
}
