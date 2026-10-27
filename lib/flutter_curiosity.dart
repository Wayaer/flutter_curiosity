/// A plugin that integrates native features for Android, iOS, macOS and HarmonyOS.
///
/// See [Curiosity] for platform helpers, [NativeTools] for native methods and
/// [ImageGalleryTools] for saving images to the system gallery.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_curiosity/src/platform/io_platform_stub.dart'
    if (dart.library.io) 'package:flutter_curiosity/src/platform/io_platform.dart';
import 'package:flutter_curiosity/src/platform/web_platform_stub.dart'
    if (dart.library.js_interop) 'package:flutter_curiosity/src/platform/web_platform.dart';

part 'src/android_activity_result.dart';
part 'src/image_gallery.dart';
part 'src/keyboard_status.dart';
part 'src/native.dart';
part 'src/package_info.dart';

const MethodChannel _channel = MethodChannel('Curiosity');

/// Entry point of the plugin.
///
/// Provides platform helpers and native tools.
class Curiosity {
  Curiosity._();

  /// Native tools, such as keyboard status, GPS status and installed apps.
  static NativeTools get native => NativeTools();

  /// Whether the app is running on web.
  static const bool isWeb = kIsWeb;

  /// Whether the app is running on macOS.
  static bool get isMacOS => !isWeb && defaultTargetPlatform == TargetPlatform.macOS;

  /// Whether the app is running on Windows.
  static bool get isWindows => !isWeb && defaultTargetPlatform == TargetPlatform.windows;

  /// Whether the app is running on Linux.
  static bool get isLinux => !isWeb && defaultTargetPlatform == TargetPlatform.linux;

  /// Whether the app is running on Android.
  static bool get isAndroid => !isWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Whether the app is running on iOS.
  static bool get isIOS => !isWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Whether the app is running on Fuchsia.
  static bool get isFuchsia => !isWeb && defaultTargetPlatform == TargetPlatform.fuchsia;

  /// Whether the app is running on HarmonyOS.
  static bool get isHarmonyOS => !isWeb && defaultTargetPlatform.name == 'ohos';

  /// Whether the app is running on a mobile device.
  static bool get isMobile => isAndroid || isIOS || isHarmonyOS;

  /// Whether the app is running on a desktop platform.
  static bool get isDesktop => isMacOS || isWindows || isLinux;

  /// Whether the app is running in release mode.
  static const bool isRelease = kReleaseMode;

  /// Whether the app is running in profile mode.
  static const bool isProfile = kProfileMode;

  /// Whether the app is running in debug mode.
  static const bool isDebug = kDebugMode;
}

/// Whether the current platform is supported by native tools.
bool get _supportPlatform {
  if (!Curiosity.isWeb && (Curiosity.isMobile || Curiosity.isMacOS)) {
    return true;
  }
  debugPrint('Curiosity is not supported on ${defaultTargetPlatform.name}');
  return false;
}

/// Dart-only plugin registration for Windows.
class CuriosityPluginWindows {
  /// Called by the Flutter tool when the plugin is registered.
  static void registerWith() {}
}

/// Dart-only plugin registration for Linux.
class CuriosityPluginLinux {
  /// Called by the Flutter tool when the plugin is registered.
  static void registerWith() {}
}
