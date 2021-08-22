import 'package:flutter/foundation.dart';

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
