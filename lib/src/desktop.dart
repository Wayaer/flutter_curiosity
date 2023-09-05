part of '../flutter_curiosity.dart';

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

  /// set desktop size to iphone 4.7
  Future<bool> setSizeTo4P7({double p = 1}) => setSize(Size(375 / p, 667 / p));

  /// set desktop size to iphone 5.5
  Future<bool> setSizeTo5P5({double p = 1}) => setSize(Size(414 / p, 736 / p));

  /// set desktop size to iphone 5.8
  Future<bool> setSizeTo5P8({double p = 1}) => setSize(Size(375 / p, 812 / p));

  /// set desktop size to iphone 6.1
  Future<bool> setSizeTo6P1({double p = 1}) => setSize(Size(414 / p, 896 / p));

  /// set desktop size to ipad 11
  Future<bool> setSizeToIPad11({double p = 1}) =>
      setSize(Size(834 / p, 1194 / p));

  /// set desktop size to ipad 10.5
  Future<bool> setSizeToIPad10P5({double p = 1}) =>
      setSize(Size(834 / p, 1112 / p));

  /// set desktop size to ipad 9.7 or 7.9
  Future<bool> setSizeToIPad9P7({double p = 1}) async {
    assert(p <= 2);
    return await setSize(Size(768 / p, 1024 / p));
  }

  /// 设置最大 size 最小 size 窗口 size
  Future<bool> setSize(Size size) async {
    final bool setSize = await setWindowSize(size);
    final bool setMin = await setMinWindowSize(size);
    final bool setMax = await setMaxWindowSize(size);
    return setSize && setMin && setMax;
  }
}
