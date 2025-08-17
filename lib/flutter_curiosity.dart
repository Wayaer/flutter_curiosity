import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'src/android_activity_result.dart';
part 'src/image_gallery.dart';
part 'src/keyboard_status.dart';
part 'src/native.dart';
part 'src/package_info.dart';

const MethodChannel _channel = MethodChannel('Curiosity');

class Curiosity {
  Curiosity._();

  ///  android ios macos
  static NativeTools get native => NativeTools();

  /// is web
  static bool get isWeb => kIsWeb;

  /// is macos
  static bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  /// is windows
  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;

  /// is linux
  static bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;

  /// is android
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  /// is ios
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  /// is fuchsia
  static bool get isFuchsia => defaultTargetPlatform == TargetPlatform.fuchsia;

  /// is harmony OS
  static bool get isHarmonyOS => defaultTargetPlatform.name == 'ohos';

  /// is mobile
  static bool get isMobile => isAndroid || isIOS || isHarmonyOS;

  /// is desktop
  static bool get isDesktop => isMacOS || isWindows || isLinux;

  /// is release
  static bool isRelease = kReleaseMode;

  /// is profile
  static bool isProfile = kProfileMode;

  /// is debug
  static bool isDebug = kDebugMode;
}

/// is support platform
bool get _supportPlatform {
  if (!Curiosity.isWeb && (Curiosity.isMobile || Curiosity.isMacOS)) {
    return true;
  }
  debugPrint('Curiosity is not support Platform');
  return false;
}
