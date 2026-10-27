import 'dart:typed_data';

/// Fallback used when `dart:js_interop` is not available, i.e. outside the web.
class WebPlatform {
  /// Returns `false` because the web platform is not available.
  static Future<bool> getGpsStatus() async => false;

  /// Returns `false` because the web platform is not available.
  static Future<bool> exitApp() async => false;

  /// Returns `false` because the web platform is not available.
  static bool addKeyboardListener(void Function(Map<String, dynamic> status) listener) => false;

  /// Does nothing because the web platform is not available.
  static void removeKeyboardListener() {}

  /// Returns `false` because the web platform is not available.
  static bool saveBytesImage(Uint8List bytes, String name, String extension) => false;
}
