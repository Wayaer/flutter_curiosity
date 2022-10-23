import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/src/internal.dart';

class DesktopTools {
  factory DesktopTools() => _singleton ??= DesktopTools._();

  DesktopTools._();

  static DesktopTools? _singleton;

  Future<Size?> getDesktopWindowSize() async {
    if (!Internal.supportPlatformDesktop) return null;
    final List<dynamic>? list = await Internal.curiosityChannel
        .invokeMethod<List<dynamic>?>('getWindowSize');
    if (list != null && list.length == 2) {
      return Size(list[0] as double, list[1] as double);
    }
    return null;
  }

  Future<bool> setDesktopWindowSize(Size size) async {
    if (!Internal.supportPlatformDesktop) return false;
    final bool? state = await Internal.curiosityChannel.invokeMethod<bool?>(
        'setWindowSize',
        <String, double>{'width': size.width, 'height': size.height});
    return state ?? false;
  }

  Future<bool> setDesktopMinWindowSize(Size size) async {
    if (!Internal.supportPlatformDesktop) return false;
    final bool? state = await Internal.curiosityChannel.invokeMethod<bool?>(
        'setMinWindowSize',
        <String, double>{'width': size.width, 'height': size.height});
    return state ?? false;
  }

  Future<bool> setDesktopMaxWindowSize(Size size) async {
    if (!Internal.supportPlatformDesktop) return false;
    final bool? state = await Internal.curiosityChannel.invokeMethod<bool?>(
        'setMaxWindowSize',
        <String, double>{'width': size.width, 'height': size.height});
    return state ?? false;
  }

  Future<bool> resetDesktopMaxWindowSize() async {
    if (!Internal.supportPlatformDesktop) return false;
    final bool? state = await Internal.curiosityChannel
        .invokeMethod<bool?>('resetMaxWindowSize');
    return state ?? false;
  }

  Future<bool> toggleDesktopFullScreen() async {
    if (!Internal.supportPlatformDesktop) return false;
    final bool? state =
        await Internal.curiosityChannel.invokeMethod<bool?>('toggleFullScreen');
    return state ?? false;
  }

  Future<bool> setDesktopFullScreen(bool fullscreen) async {
    if (!Internal.supportPlatformDesktop) return false;
    final bool? state = await Internal.curiosityChannel.invokeMethod<bool?>(
        'setFullScreen', <String, bool>{'fullscreen': fullscreen});
    return state ?? false;
  }

  Future<bool?> getDesktopFullScreen() async {
    if (!Internal.supportPlatformDesktop) return null;
    final bool? fullscreen =
        await Internal.curiosityChannel.invokeMethod<bool?>('getFullScreen');
    if (fullscreen is bool) return fullscreen;
    return null;
  }

  Future<bool> get hasDesktopBorders async {
    if (!Internal.supportPlatformDesktop) return false;
    final bool? hasBorders =
        await Internal.curiosityChannel.invokeMethod<bool?>('hasBorders');
    if (hasBorders is bool) return hasBorders;
    return hasBorders ?? false;
  }

  Future<bool> toggleDesktopBorders() async {
    if (!Internal.supportPlatformDesktop) return false;
    final bool? state =
        await Internal.curiosityChannel.invokeMethod<bool?>('toggleBorders');
    return state ?? false;
  }

  Future<bool> setDesktopBorders(bool border) async {
    if (!Internal.supportPlatformDesktop) return false;
    final bool? state = await Internal.curiosityChannel
        .invokeMethod<bool?>('setBorders', <String, dynamic>{'border': border});
    return state ?? false;
  }

  Future<bool> stayOnTopWithDesktop([bool stayOnTop = true]) async {
    if (!Internal.supportPlatformDesktop) return false;
    final bool? state = await Internal.curiosityChannel.invokeMethod<bool?>(
        'stayOnTop', <String, dynamic>{'stayOnTop': stayOnTop});
    return state ?? false;
  }

  Future<bool> focusDesktop() async {
    if (!Internal.supportPlatformDesktop) return false;
    final bool? state =
        await Internal.curiosityChannel.invokeMethod<bool?>('focus');
    return state ?? false;
  }

  /// set desktop size to iphone 4.7
  Future<bool> setDesktopSizeTo4P7({double p = 1}) =>
      setDesktopSize(Size(375 / p, 667 / p));

  /// set desktop size to iphone 5.5
  Future<bool> setDesktopSizeTo5P5({double p = 1}) =>
      setDesktopSize(Size(414 / p, 736 / p));

  /// set desktop size to iphone 5.8
  Future<bool> setDesktopSizeTo5P8({double p = 1}) =>
      setDesktopSize(Size(375 / p, 812 / p));

  /// set desktop size to iphone 6.1
  Future<bool> setDesktopSizeTo6P1({double p = 1}) =>
      setDesktopSize(Size(414 / p, 896 / p));

  /// set desktop size to ipad 11
  Future<bool> setDesktopSizeToIPad11({double p = 1}) =>
      setDesktopSize(Size(834 / p, 1194 / p));

  /// set desktop size to ipad 10.5
  Future<bool> setDesktopSizeToIPad10P5({double p = 1}) =>
      setDesktopSize(Size(834 / p, 1112 / p));

  /// set desktop size to ipad 9.7 or 7.9
  Future<bool> setDesktopSizeToIPad9P7({double p = 1}) async {
    assert(p <= 2);
    return await setDesktopSize(Size(768 / p, 1024 / p));
  }

  /// 设置最大 size 最小 size 窗口 size
  Future<bool> setDesktopSize(Size size) async {
    final bool setSize = await setDesktopWindowSize(size);
    final bool setMin = await setDesktopMinWindowSize(size);
    final bool setMax = await setDesktopMaxWindowSize(size);
    return setSize && setMin && setMax;
  }

  /// 文件选择器macos
  Future<List<String>> openFilePicker(
      {FilePickerOptionsWithMacOS? optionsWithMacOS}) async {
    if (!isMacOS) return <String>[];
    Map<String, dynamic> options = <String, dynamic>{};
    if (isMacOS) {
      optionsWithMacOS ??= FilePickerOptionsWithMacOS();
      options = optionsWithMacOS.toMap();
    }
    final List<dynamic>? path =
        await Internal.curiosityChannel.invokeMethod('openFilePicker', options);
    return path?.map((dynamic e) => e as String).toList() ?? <String>[];
  }

  /// 保存文件选择器macos
  Future<String?> saveFilePicker(
      {SaveFilePickerOptionsWithMacOS? optionsWithMacOS}) async {
    if (!isMacOS) return null;
    Map<String, dynamic> options = <String, dynamic>{};
    if (isMacOS) {
      optionsWithMacOS ??= SaveFilePickerOptionsWithMacOS();
      options = optionsWithMacOS.toMap();
    }
    final String? path =
        await Internal.curiosityChannel.invokeMethod('saveFilePicker', options);
    return path;
  }
}
