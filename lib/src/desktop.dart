part of '../flutter_curiosity.dart';

enum DesktopWindowsSize {
  /// set desktop size to iphone 4.7
  iPhone4P7(Size(375, 667)),

  /// set desktop size to iphone 5.5
  iPhone5P5(Size(414, 736)),

  /// set desktop size to iphone 5.8
  iPhone5P8(Size(375, 812)),

  /// set desktop size to iphone 6.1
  iPhone6P1(Size(414, 896)),

  /// set desktop size to ipad 9.7
  iPad9P7(Size(768, 1024)),

  /// set desktop size to 7.9
  iPad7P9(Size(1024, 768)),

  /// set desktop size to ipad 10.5
  iPad10P5(Size(834, 1112)),

  /// set desktop size to ipad 11
  iPad11(Size(834, 1194)),
  ;

  const DesktopWindowsSize(this.size);

  final Size size;

  Size get value => size;

  Future<bool> set() => DesktopTools().setSize(size);
}

class DesktopTools {
  factory DesktopTools() => _singleton ??= DesktopTools._();

  DesktopTools._();

  static DesktopTools? _singleton;

  /// getWindowSize
  Future<Size?> getWindowSize() async {
    if (!_supportPlatformDesktop) return null;
    final List<dynamic>? list =
        await _channel.invokeMethod<List<dynamic>?>('getWindowSize');
    if (list != null && list.length == 2) {
      return Size(list[0] as double, list[1] as double);
    }
    return null;
  }

  Future<bool> setWindowSize(Size size) async {
    if (!_supportPlatformDesktop) return false;
    final bool? state = await _channel.invokeMethod<bool?>('setWindowSize',
        <String, double>{'width': size.width, 'height': size.height});
    return state ?? false;
  }

  Future<bool> setMinWindowSize(Size size) async {
    if (!_supportPlatformDesktop) return false;
    final bool? state = await _channel.invokeMethod<bool?>('setMinWindowSize',
        <String, double>{'width': size.width, 'height': size.height});
    return state ?? false;
  }

  Future<bool> setMaxWindowSize(Size size) async {
    if (!_supportPlatformDesktop) return false;
    final bool? state = await _channel.invokeMethod<bool?>('setMaxWindowSize',
        <String, double>{'width': size.width, 'height': size.height});
    return state ?? false;
  }

  Future<bool> resetMaxWindowSize() async {
    if (!_supportPlatformDesktop) return false;
    final bool? state =
        await _channel.invokeMethod<bool?>('resetMaxWindowSize');
    return state ?? false;
  }

  Future<bool> toggleFullScreen() async {
    if (!_supportPlatformDesktop) return false;
    final bool? state = await _channel.invokeMethod<bool?>('toggleFullScreen');
    return state ?? false;
  }

  Future<bool> setFullScreen(bool fullscreen) async {
    if (!_supportPlatformDesktop) return false;
    final bool? state = await _channel.invokeMethod<bool?>(
        'setFullScreen', <String, bool>{'fullscreen': fullscreen});
    return state ?? false;
  }

  Future<bool?> getFullScreen() async {
    if (!_supportPlatformDesktop) return null;
    final bool? fullscreen =
        await _channel.invokeMethod<bool?>('getFullScreen');
    if (fullscreen is bool) return fullscreen;
    return null;
  }

  Future<bool> get hasBorders async {
    if (!_supportPlatformDesktop) return false;
    final bool? hasBorders = await _channel.invokeMethod<bool?>('hasBorders');
    if (hasBorders is bool) return hasBorders;
    return hasBorders ?? false;
  }

  Future<bool> toggleBorders() async {
    if (!_supportPlatformDesktop) return false;
    final bool? state = await _channel.invokeMethod<bool?>('toggleBorders');
    return state ?? false;
  }

  Future<bool> setBorders(bool border) async {
    if (!_supportPlatformDesktop) return false;
    final bool? state = await _channel
        .invokeMethod<bool?>('setBorders', <String, dynamic>{'border': border});
    return state ?? false;
  }

  Future<bool> stayOnTop([bool stayOnTop = true]) async {
    if (!_supportPlatformDesktop) return false;
    final bool? state = await _channel.invokeMethod<bool?>(
        'stayOnTop', <String, dynamic>{'stayOnTop': stayOnTop});
    return state ?? false;
  }

  Future<bool> focus() async {
    if (!_supportPlatformDesktop) return false;
    final bool? state = await _channel.invokeMethod<bool?>('focus');
    return state ?? false;
  }

  /// 设置最大 size 最小 size 窗口 size
  Future<bool> setSize(Size size) async {
    final bool setSize = await setWindowSize(size);
    final bool setMin = await setMinWindowSize(size);
    final bool setMax = await setMaxWindowSize(size);
    return setSize && setMin && setMax;
  }
}
