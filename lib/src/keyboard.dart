part of '../flutter_curiosity.dart';

class NativeKeyboardStatus {
  final Map<dynamic, dynamic> _map;

  NativeKeyboardStatus.formMap(this._map) {
    if (Curiosity.isAndroid) {
      _android = AndroidKeyboardParams.formMap(_map);
    }
    if (Curiosity.isIOS) {
      _ios = IOSKeyboardParams.formMap(_map);
    }
  }

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
    }
    return false;
  }

  /// keyboardHeight
  /// android is px
  /// supports iOS Android
  double? get keyboardHeight {
    if (Curiosity.isAndroid && _android != null) {
      return _android!.keyboardHeight / _android!.density;
    } else if (Curiosity.isIOS) {
      return _ios!.height;
    }
    return null;
  }
}

class IOSKeyboardParams {
  IOSKeyboardParams.formMap(Map<dynamic, dynamic> map)
      : height = map['height'] as double? ?? 0,
        width = map['width'] as double? ?? 0,
        visibility = map['visibility'] as bool? ?? false;

  /// 键盘是否显示
  final bool visibility;

  /// 键盘高度
  final double height;

  /// 键盘宽度
  final double width;
}

class AndroidKeyboardParams {
  AndroidKeyboardParams.formMap(Map<dynamic, dynamic> map)
      : density = map['density'] as double? ?? 0,
        rootHeight = map['rootHeight'] as int? ?? 0,
        rootWidth = map['rootWidth'] as int? ?? 0,
        left = map['left'] as int? ?? 0,
        top = map['top'] as int? ?? 0,
        right = map['right'] as int? ?? 0,
        bottom = map['bottom'] as int? ?? 0 {
    if (!visibility) _navigationBarHeight = keyboardHeight;
  }

  /// [MediaQuery.of(this).devicePixelRatio]
  /// 要转换 flutter 单位需要 value/[density]
  final double density;

  /// 整个 view 的宽高  px
  final int rootHeight;
  final int rootWidth;

  /// 没有被键盘遮挡的区域  px
  final int left;
  final int top;
  final int right;
  final int bottom;

  /// 键盘的高度 如果有导航栏 导航栏也是会包含
  int get keyboardHeight => rootHeight - bottom;

  /// 导航栏高度
  /// 当键盘关闭时 [keyboardHeight] 如果有值那就是导航栏高度，需要单独保存
  /// 当键盘打开时 无法判断导航栏高度
  int _navigationBarHeight = 0;

  int get navigationBarHeight => _navigationBarHeight;

  /// 键盘是否显示
  bool get visibility => (bottom / rootHeight) < 0.85;
}
