import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'src/native.dart';

part 'src/package_info.dart';

part 'src/image_gallery.dart';

const MethodChannel _channel = MethodChannel('Curiosity');

class Curiosity {
  Curiosity._();

  ///  android ios macos
  static NativeTools get native => NativeTools();

  static bool get isWeb => kIsWeb;

  static bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;

  static bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;

  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isFuchsia => defaultTargetPlatform == TargetPlatform.fuchsia;

  static bool get isMobile => isAndroid || isIOS;

  static bool get isDesktop => isMacOS || isWindows || isLinux;

  static bool get isRelease => kReleaseMode;

  static bool get isProfile => kProfileMode;

  static bool get isDebug => kDebugMode;
}

bool get _supportPlatform {
  if (!Curiosity.isWeb && (Curiosity.isMobile || Curiosity.isMacOS)) {
    return true;
  }
  debugPrint('Curiosity is not support Platform');
  return false;
}
