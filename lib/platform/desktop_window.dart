import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_curiosity/constant/constant.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/tools/internal.dart';

Future<Size?> getDesktopWindowSize() async {
  if (!supportPlatformDesktop) return null;
  final List<dynamic>? list =
      await curiosityChannel.invokeMethod<List<dynamic>?>('getWindowSize');
  if (list != null && list is List && list.length == 2)
    return Size(list[0] as double, list[1] as double);
  return null;
}

Future<bool> setDesktopWindowSize(Size size) async {
  if (!supportPlatformDesktop) return false;
  final bool? state = await curiosityChannel.invokeMethod<bool?>(
      'setWindowSize',
      <String, double>{'width': size.width, 'height': size.height});
  return state ?? false;
}

Future<bool> setDesktopMinWindowSize(Size size) async {
  if (!supportPlatformDesktop) return false;
  final bool? state = await curiosityChannel.invokeMethod<bool?>(
      'setMinWindowSize',
      <String, double>{'width': size.width, 'height': size.height});
  return state ?? false;
}

Future<bool> setDesktopMaxWindowSize(Size size) async {
  if (!supportPlatformDesktop) return false;
  final bool? state = await curiosityChannel.invokeMethod<bool?>(
      'setMaxWindowSize',
      <String, double>{'width': size.width, 'height': size.height});
  return state ?? false;
}

Future<bool> resetDesktopMaxWindowSize() async {
  if (!supportPlatformDesktop) return false;
  final bool? state =
      await curiosityChannel.invokeMethod<bool?>('resetMaxWindowSize');
  return state ?? false;
}

Future<bool> toggleDesktopFullScreen() async {
  if (!supportPlatformDesktop) return false;
  final bool? state =
      await curiosityChannel.invokeMethod<bool?>('toggleFullScreen');
  return state ?? false;
}

Future<bool> setDesktopFullScreen(bool fullscreen) async {
  if (!supportPlatformDesktop) return false;
  final bool? state = await curiosityChannel.invokeMethod<bool?>(
      'setFullScreen', <String, bool>{'fullscreen': fullscreen});
  return state ?? false;
}

Future<bool?> getDesktopFullScreen() async {
  if (!supportPlatformDesktop) return null;
  final bool? fullscreen =
      await curiosityChannel.invokeMethod<bool?>('getFullScreen');
  if (fullscreen is bool) return fullscreen;
  return null;
}

Future<bool> get hasDesktopBorders async {
  if (!supportPlatformDesktop) return false;
  final bool? hasBorders =
      await curiosityChannel.invokeMethod<bool?>('hasBorders');
  if (hasBorders is bool) return hasBorders;
  return hasBorders ?? false;
}

Future<bool> toggleDesktopBorders() async {
  if (!supportPlatformDesktop) return false;
  final bool? state =
      await curiosityChannel.invokeMethod<bool?>('toggleBorders');
  return state ?? false;
}

Future<bool> setDesktopBorders(bool border) async {
  if (!supportPlatformDesktop) return false;
  final bool? state = await curiosityChannel
      .invokeMethod<bool?>('setBorders', <String, dynamic>{'border': border});
  return state ?? false;
}

Future<bool> stayOnTopWithDesktop([bool stayOnTop = true]) async {
  if (!supportPlatformDesktop) return false;
  final bool? state = await curiosityChannel.invokeMethod<bool?>(
      'stayOnTop', <String, dynamic>{'stayOnTop': stayOnTop});
  return state ?? false;
}

Future<bool> focusDesktop() async {
  if (!supportPlatformDesktop) return false;
  final bool? state = await curiosityChannel.invokeMethod<bool?>('focus');
  return state ?? false;
}

/// set desktop size to iphone 4.7
Future<bool> setDesktopSizeTo4P7({double p = 1}) =>
    _setDesktopSize(Size(375 / p, 667 / p));

/// set desktop size to iphone 5.5
Future<bool> setDesktopSizeTo5P5({double p = 1}) =>
    _setDesktopSize(Size(414 / p, 736 / p));

/// set desktop size to iphone 5.8
Future<bool> setDesktopSizeTo5P8({double p = 1}) =>
    _setDesktopSize(Size(375 / p, 812 / p));

/// set desktop size to iphone 6.1
Future<bool> setDesktopSizeTo6P1({double p = 1}) =>
    _setDesktopSize(Size(414 / p, 896 / p));

/// set desktop size to ipad 11
Future<bool> setDesktopSizeToIPad11({double p = 1}) =>
    _setDesktopSize(Size(834 / p, 1194 / p));

/// set desktop size to ipad 10.5
Future<bool> setDesktopSizeToIPad10P5({double p = 1}) =>
    _setDesktopSize(Size(834 / p, 1112 / p));

/// set desktop size to ipad 9.7 or 7.9
Future<bool> setDesktopSizeToIPad9P7({double p = 1}) async {
  assert(p <= 2);
  return await _setDesktopSize(Size(768 / p, 1024 / p));
}

Future<bool> _setDesktopSize(Size size) async {
  final bool _size = await setDesktopWindowSize(size);
  final bool _min = await setDesktopMinWindowSize(size);
  final bool _max = await setDesktopMaxWindowSize(size);
  return _size && _min && _max;
}
