part of '../flutter_curiosity.dart';

/// Keyboard status reported by the native platform.
class NativeKeyboardStatus {
  /// Creates a keyboard status from a map received from the native platform.
  NativeKeyboardStatus.fromMap(Map<dynamic, dynamic> map) {
    if (Curiosity.isAndroid) {
      _android = AndroidKeyboardParams.fromMap(map);
    } else if (Curiosity.isIOS) {
      _ios = IOSKeyboardParams.fromMap(map);
    } else if (Curiosity.isHarmonyOS) {
      _harmonyOS = HarmonyOSKeyboardParams.fromMap(map);
    } else if (Curiosity.isWeb) {
      _web = WebKeyboardParams.fromMap(map);
    }
  }

  WebKeyboardParams? _web;

  /// Web keyboard params, only available on web.
  WebKeyboardParams? get web => _web;

  HarmonyOSKeyboardParams? _harmonyOS;

  /// HarmonyOS keyboard params, only available on HarmonyOS.
  HarmonyOSKeyboardParams? get harmonyOS => _harmonyOS;

  AndroidKeyboardParams? _android;

  /// Android keyboard params, only available on Android.
  AndroidKeyboardParams? get android => _android;

  IOSKeyboardParams? _ios;

  /// iOS keyboard params, only available on iOS.
  IOSKeyboardParams? get ios => _ios;

  /// Whether the keyboard is visible.
  bool get visibility {
    if (Curiosity.isAndroid) return _android?.visibility ?? false;
    if (Curiosity.isIOS) return _ios?.visibility ?? false;
    if (Curiosity.isHarmonyOS) return _harmonyOS?.visibility ?? false;
    if (Curiosity.isWeb) return _web?.visibility ?? false;
    return false;
  }

  /// The keyboard height in logical pixels.
  ///
  /// Supported on Android, iOS, HarmonyOS and web.
  num? get keyboardHeight {
    if (Curiosity.isAndroid) {
      final AndroidKeyboardParams? params = _android;
      if (params != null && params.density > 0) return params.keyboardHeight / params.density;
    } else if (Curiosity.isIOS) {
      return _ios?.height;
    } else if (Curiosity.isHarmonyOS) {
      final HarmonyOSKeyboardParams? params = _harmonyOS;
      if (params != null && params.density > 0) return params.keyboardHeight / params.density;
    } else if (Curiosity.isWeb) {
      return _web?.height;
    }
    return null;
  }
}

/// iOS keyboard params.
class IOSKeyboardParams {
  /// Creates iOS keyboard params from a map received from iOS.
  IOSKeyboardParams.fromMap(Map<dynamic, dynamic> map)
    : height = map['height'] as num? ?? 0,
      width = map['width'] as num? ?? 0,
      visibility = map['visibility'] as bool? ?? false;

  /// Whether the keyboard is visible.
  final bool visibility;

  /// The keyboard height. It has a value even when [visibility] is `false`.
  final num height;

  /// The keyboard width.
  final num width;
}

/// Android keyboard params.
class AndroidKeyboardParams {
  /// Creates Android keyboard params from a map received from Android.
  AndroidKeyboardParams.fromMap(Map<dynamic, dynamic> map)
    : density = map['density'] as double? ?? 0,
      rootHeight = map['rootHeight'] as num? ?? 0,
      rootWidth = map['rootWidth'] as num? ?? 0,
      left = map['left'] as num? ?? 0,
      top = map['top'] as num? ?? 0,
      right = map['right'] as num? ?? 0,
      bottom = map['bottom'] as num? ?? 0 {
    if (!visibility) _navigationBarHeight = keyboardHeight;
  }

  /// The device pixel ratio.
  ///
  /// Use `value / density` to convert a value to Flutter logical pixels.
  final double density;

  /// The height of the whole view in physical pixels.
  final num rootHeight;

  /// The width of the whole view in physical pixels.
  final num rootWidth;

  /// The left coordinate of the visible area in physical pixels.
  final num left;

  /// The top coordinate of the visible area in physical pixels.
  final num top;

  /// The right coordinate of the visible area in physical pixels.
  final num right;

  /// The bottom coordinate of the visible area in physical pixels.
  final num bottom;

  /// The keyboard height in physical pixels, including the navigation bar.
  num get keyboardHeight {
    final num height = rootHeight - bottom;
    return height < 0 ? 0 : height;
  }

  num _navigationBarHeight = 0;

  /// The navigation bar height.
  ///
  /// When the keyboard is hidden, [keyboardHeight] is the navigation bar height.
  num get navigationBarHeight => _navigationBarHeight;

  /// Whether the keyboard is visible.
  bool get visibility => rootHeight > 0 && (bottom / rootHeight) < 0.85;
}

/// HarmonyOS keyboard params.
class HarmonyOSKeyboardParams {
  /// Creates HarmonyOS keyboard params from a map received from HarmonyOS.
  HarmonyOSKeyboardParams.fromMap(Map<dynamic, dynamic> map)
    : density = map['density'] as num? ?? 0,
      displayHeight = map['displayHeight'] as num? ?? 0,
      displayWidth = map['displayWidth'] as num? ?? 0,
      keyboardHeight = map['keyboardHeight'] as num? ?? 0;

  /// The device pixel ratio.
  ///
  /// Use `value / density` to convert a value to Flutter logical pixels.
  final num density;

  /// The height of the whole display in physical pixels.
  final num displayHeight;

  /// The width of the whole display in physical pixels.
  final num displayWidth;

  /// The keyboard height in physical pixels.
  final num keyboardHeight;

  /// Whether the keyboard is visible.
  bool get visibility => displayHeight > 0 && keyboardHeight > 0 && (keyboardHeight / displayHeight) < 0.85;
}

/// Web keyboard params.
class WebKeyboardParams {
  /// Creates web keyboard params from a map received from the browser.
  WebKeyboardParams.fromMap(Map<dynamic, dynamic> map)
    : visibility = map['visibility'] as bool? ?? false,
      height = map['height'] as num? ?? 0,
      width = map['width'] as num? ?? 0;

  /// Whether the keyboard is visible.
  final bool visibility;

  /// The keyboard height in CSS pixels.
  final num height;

  /// The visible viewport width in CSS pixels.
  final num width;
}

/// Mixin that listens to keyboard status changes.
mixin NativeKeyboardStatusMixin {
  NativeKeyboardStatus? _keyboardParams;

  /// The latest keyboard status.
  NativeKeyboardStatus? get keyboardParams => _keyboardParams;

  /// Whether the keyboard is visible.
  bool get keyboardVisible => _keyboardParams?.visibility ?? false;

  /// Adds a keyboard listener.
  Future<bool> addKeyboardListener() async {
    try {
      return await NativeTools.instance.addKeyboardListener(onKeyboardListener);
    } on Exception catch (e) {
      debugPrint('addKeyboardListener error = $e');
      return false;
    }
  }

  /// Called when the keyboard status changes. Override to handle it.
  void onKeyboardListener(NativeKeyboardStatus params) {
    _keyboardParams = params;
  }

  /// Removes the keyboard listener.
  Future<bool> removeKeyboardListener() async {
    try {
      return await NativeTools.instance.removeKeyboardListener(onKeyboardListener);
    } on Exception catch (e) {
      debugPrint('removeKeyboardListener error = $e');
      return false;
    }
  }
}

/// A [State] that listens to keyboard status changes.
abstract class NativeKeyboardStatusState<T extends StatefulWidget> extends State<T> with NativeKeyboardStatusMixin {
  @override
  void initState() {
    super.initState();
    addKeyboardListener();
  }

  @override
  void dispose() {
    removeKeyboardListener();
    super.dispose();
  }
}
