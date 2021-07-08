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

Future<void> setDesktopWindowSize(Size size) async {
  if (!supportPlatformDesktop) return;
  curiosityChannel.invokeMethod<dynamic>('setWindowSize',
      <String, double>{'width': size.width, 'height': size.height});
}

Future<void> setDesktopMinWindowSize(Size size) async {
  if (!supportPlatformDesktop) return;
  curiosityChannel.invokeMethod<dynamic>('setMinWindowSize',
      <String, double>{'width': size.width, 'height': size.height});
}

Future<void> setDesktopMaxWindowSize(Size size) async {
  if (!supportPlatformDesktop) return;
  curiosityChannel.invokeMethod<dynamic>('setMaxWindowSize',
      <String, double>{'width': size.width, 'height': size.height});
}

Future<void> resetDesktopMaxWindowSize() async {
  if (!supportPlatformDesktop) return;
  curiosityChannel.invokeMethod<dynamic>('resetMaxWindowSize');
}

Future<void> toggleDesktopFullScreen() async {
  if (!supportPlatformDesktop) return;
  curiosityChannel.invokeMethod<dynamic>('toggleFullScreen');
}

Future<void> setDesktopFullScreen(bool fullscreen) async {
  if (!supportPlatformDesktop) return;
  curiosityChannel.invokeMethod<dynamic>(
      'setFullScreen', <String, bool>{'fullscreen': fullscreen});
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
      await curiosityChannel.invokeMethod<bool>('hasBorders');
  if (hasBorders is bool) return hasBorders;
  return hasBorders ?? false;
}

Future<void> toggleDesktopBorders() async {
  if (!supportPlatformDesktop) return;
  curiosityChannel.invokeMethod<dynamic>('toggleBorders');
}

Future<void> setDesktopBorders(bool border) async {
  if (!supportPlatformDesktop) return;
  curiosityChannel
      .invokeMethod<dynamic>('setBorders', <String, dynamic>{'border': border});
}

Future<void> stayOnTopWithDesktop([bool stayOnTop = true]) async {
  if (!supportPlatformDesktop) return;
  if (!isWeb && (isWindows || isLinux || isMacOS))
    curiosityChannel.invokeMethod<dynamic>(
        'stayOnTop', <String, dynamic>{'stayOnTop': stayOnTop});
}

Future<void> focusDesktop() async {
  if (!supportPlatformDesktop) return;
  curiosityChannel.invokeMethod<dynamic>('focus');
}

/// set desktop size to iphone 4.7
void setDesktopSizeTo4P7({double p = 1}) {
  if (!supportPlatformDesktop) return;
  final Size size = Size(375 / p, 667 / p);
  setDesktopWindowSize(size);
  setDesktopMinWindowSize(size);
  setDesktopMaxWindowSize(size);
}

/// set desktop size to iphone 5.5
void setDesktopSizeTo5P5({double p = 1}) {
  if (!supportPlatformDesktop) return;
  final Size size = Size(414 / p, 736 / p);
  setDesktopWindowSize(size);
  setDesktopMinWindowSize(size);
  setDesktopMaxWindowSize(size);
}

/// set desktop size to iphone 5.8
void setDesktopSizeTo5P8({double p = 1}) {
  if (!supportPlatformDesktop) return;
  final Size size = Size(375 / p, 812 / p);
  setDesktopWindowSize(size);
  setDesktopMinWindowSize(size);
  setDesktopMaxWindowSize(size);
}

/// set desktop size to iphone 6.1
void setDesktopSizeTo6P1({double p = 1}) {
  if (!supportPlatformDesktop) return;
  final Size size = Size(414 / p, 896 / p);
  setDesktopWindowSize(size);
  setDesktopMinWindowSize(size);
  setDesktopMaxWindowSize(size);
}

/// set desktop size to ipad 11
void setDesktopSizeToIPad11({double p = 1}) {
  if (!supportPlatformDesktop) return;
  final Size size = Size(834 / p, 1194 / p);
  setDesktopWindowSize(size);
  setDesktopMinWindowSize(size);
  setDesktopMaxWindowSize(size);
}

/// set desktop size to ipad 10.5
void setDesktopSizeToIPad10P5({double p = 1}) {
  if (!supportPlatformDesktop) return;
  final Size size = Size(834 / p, 1112 / p);
  setDesktopWindowSize(size);
  setDesktopMinWindowSize(size);
  setDesktopMaxWindowSize(size);
}

/// set desktop size to ipad 9.7 or 7.9
void setDesktopSizeToIPad9P7({double p = 1}) {
  if (!supportPlatformDesktop) return;
  assert(p <= 2);
  final Size size = Size(768 / p, 1024 / p);
  setDesktopWindowSize(size);
  setDesktopMinWindowSize(size);
  setDesktopMaxWindowSize(size);
}
