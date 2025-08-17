part of '../flutter_curiosity.dart';

class NativeKeyboardStatus {
  final Map<dynamic, dynamic> _map;

  NativeKeyboardStatus.fromMap(this._map) {
    if (Curiosity.isAndroid) {
      _android = AndroidKeyboardParams.fromMap(_map);
    } else if (Curiosity.isIOS) {
      _ios = IOSKeyboardParams.fromMap(_map);
    } else if (Curiosity.isHarmonyOS) {
      _harmonyOS = HarmonyOSKeyboardParams.fromMap(_map);
    }
  }

  /// harmony os
  HarmonyOSKeyboardParams? _harmonyOS;

  HarmonyOSKeyboardParams? get harmonyOS => _harmonyOS;

  /// android
  AndroidKeyboardParams? _android;

  AndroidKeyboardParams? get android => _android;

  /// ios
  IOSKeyboardParams? _ios;

  IOSKeyboardParams? get ios => _ios;

  /// visibility
  bool get visibility {
    if (Curiosity.isAndroid) {
      return _android?.visibility ?? false;
    } else if (Curiosity.isIOS) {
      return _ios?.visibility ?? false;
    } else if (Curiosity.isHarmonyOS) {
      return _harmonyOS?.visibility ?? false;
    }
    return false;
  }

  /// keyboardHeight
  /// supports iOS Android
  num? get keyboardHeight {
    if (Curiosity.isAndroid) {
      if (_android != null) return _android!.keyboardHeight / _android!.density;
    } else if (Curiosity.isIOS) {
      return _ios?.height;
    } else if (Curiosity.isHarmonyOS) {
      if (_harmonyOS != null) {
        return _harmonyOS!.keyboardHeight / _harmonyOS!.density;
      }
    }
    return null;
  }
}

class IOSKeyboardParams {
  IOSKeyboardParams.fromMap(Map<dynamic, dynamic> map)
      : height = map['height'] as num? ?? 0,
        width = map['width'] as num? ?? 0,
        visibility = map['visibility'] as bool? ?? false;

  /// 键盘是否显示
  final bool visibility;

  /// 键盘高度 [visibility] = false [height] 依然有值
  final num height;

  /// 键盘宽度
  final num width;
}

class AndroidKeyboardParams {
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

  /// [MediaQuery.of(this).devicePixelRatio]
  /// 要转换 flutter 单位需要 value/[density]
  final double density;

  /// 整个 view 的宽高  px
  final num rootHeight;
  final num rootWidth;

  /// 没有被键盘遮挡的区域  px
  final num left;
  final num top;
  final num right;
  final num bottom;

  /// 键盘原始高度 px 如果有导航栏 导航栏也是会包含
  num get keyboardHeight => rootHeight - bottom;

  /// 导航栏高度
  /// 当键盘关闭时 [keyboardHeight] 如果有值那就是导航栏高度，需要单独保存
  /// 当键盘打开时 无法判断导航栏高度
  num _navigationBarHeight = 0;

  num get navigationBarHeight => _navigationBarHeight;

  /// 键盘是否显示
  bool get visibility => (bottom / rootHeight) < 0.85;
}

class HarmonyOSKeyboardParams {
  HarmonyOSKeyboardParams.fromMap(Map<dynamic, dynamic> map)
      : density = map['density'] as num? ?? 0,
        displayHeight = map['displayHeight'] as num? ?? 0,
        displayWidth = map['displayWidth'] as num? ?? 0,
        keyboardHeight = map['keyboardHeight'] as num? ?? 0;

  /// [MediaQuery.of(this).devicePixelRatio]
  /// 要转换 flutter 单位需要 value/[density]
  final num density;

  /// 整个 设备的 宽高  px
  final num displayHeight;
  final num displayWidth;

  /// 键盘原始高度 px
  final num keyboardHeight;

  /// 键盘是否显示
  bool get visibility =>
      (keyboardHeight / displayHeight) < 0.85 && keyboardHeight > 0;
}

mixin NativeKeyboardStatusMixin {
  NativeKeyboardStatus? _keyboardParams;

  NativeKeyboardStatus? get keyboardParams => _keyboardParams;

  /// 键盘是否显示
  bool get keyboardVisible => _keyboardParams?.visibility ?? false;

  /// 键盘监听回调
  Future<bool> addKeyboardListener() {
    try {
      return NativeTools().addKeyboardListener(onKeyboardListener);
    } catch (e) {
      debugPrint('addKeyboardListener error = $e');
      return Future.value(false);
    }
  }

  /// 键盘监听回调
  void onKeyboardListener(NativeKeyboardStatus params) {
    _keyboardParams = params;
  }

  /// 移除键盘监听回调
  Future<bool> removeKeyboardListener() {
    try {
      return NativeTools().removeKeyboardListener(onKeyboardListener);
    } catch (e) {
      debugPrint('removeKeyboardListener error = $e');
      return Future.value(false);
    }
  }
}

abstract class NativeKeyboardStatusState<T extends StatefulWidget>
    extends State<T> with NativeKeyboardStatusMixin {
  @override
  void initState() {
    super.initState();
    addKeyboardListener();
  }

  @override
  void dispose() {
    super.dispose();
    removeKeyboardListener();
  }
}
