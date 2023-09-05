library flutter_curiosity;

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'src/desktop.dart';

part 'src/native.dart';

const MethodChannel _channel = MethodChannel('Curiosity');

class Curiosity {
  factory Curiosity() => _singleton ??= Curiosity._();

  Curiosity._();

  static Curiosity? _singleton;

  NativeTools get native => NativeTools();

  DesktopTools get desktop => DesktopTools();
}

bool get _supportPlatformDesktop {
  if (!isWeb && isDesktop) return true;
  debugPrint('Curiosity is not support Platform');
  return false;
}

bool get _supportPlatform {
  if (!isWeb && (isMobile || isMacOS)) return true;
  debugPrint('Curiosity is not support Platform');
  return false;
}

bool get _supportPlatformMobile {
  if (isMobile) return true;
  debugPrint('Curiosity is not support Platform');
  return false;
}

bool get isWeb => kIsWeb;

bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;

bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;

bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

bool get isFuchsia => defaultTargetPlatform == TargetPlatform.fuchsia;

bool get isMobile => isAndroid || isIOS;

bool get isDesktop => isMacOS || isWindows || isLinux;

bool get isRelease => kReleaseMode;

bool get isProfile => kProfileMode;

bool get isDebug => kDebugMode;
