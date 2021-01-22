import 'package:flutter/foundation.dart';
import 'package:flutter_curiosity/platform/platform_html.dart'
    if (dart.library.io) 'package:flutter_curiosity/platform/platform_io.dart';

bool get isWeb => kIsWeb;

bool get isMacOS => isInternalMacOS;

bool get isWindows => isInternalWindows;

bool get isLinux => isInternalLinux;

bool get isAndroid => isInternalAndroid;

bool get isIOS => isInternalIOS;

bool get isFuchsia => isInternalFuchsia;

bool get isMobile => isInternalAndroid || isInternalIOS;

bool get isDesktop => isInternalMacOS || isInternalWindows || isInternalLinux;

bool get isRelease => kReleaseMode;

bool get isProfile => kProfileMode;

bool get isDebug => kDebugMode;
