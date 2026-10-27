import 'dart:typed_data';

/// Fallback used when `dart:io` is not available, e.g. on the web.
class IoPlatform {
  /// Returns `false` because exiting the app is not supported.
  static Future<bool> exitApp() async => false;

  /// Returns `false` because saving to a folder is not supported.
  static Future<bool> saveBytesImage(Uint8List bytes, String name, String extension) async => false;

  /// Returns `false` because saving to a folder is not supported.
  static Future<bool> saveFilePath(String path, String name, String extension) async => false;
}
