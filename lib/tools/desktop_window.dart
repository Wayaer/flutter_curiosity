import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_curiosity/constant/constant.dart';
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

Future<void> setDesktopFullScreen(bool fullscreen) => curiosityChannel
    .invokeMethod('setFullScreen', <String, bool>{'fullscreen': fullscreen});

Future<bool?> getDesktopFullScreen() async {
  if (!supportPlatformDesktop) return null;
  final bool? fullscreen =
      await curiosityChannel.invokeMethod<bool?>('getFullScreen');
  if (fullscreen is bool) return fullscreen;
  return null;
}

/// set desktop size to iphone 4.7
void setDesktopSizeTo4P7() {
  setDesktopWindowSize(const Size(375, 667));
  setDesktopMinWindowSize(const Size(375, 667));
  setDesktopMaxWindowSize(const Size(375, 667));
}

/// set desktop size to iphone 5.5
void setDesktopSizeTo5P5() {
  setDesktopWindowSize(const Size(414, 736));
  setDesktopMinWindowSize(const Size(414, 736));
  setDesktopMaxWindowSize(const Size(414, 736));
}

/// set desktop size to iphone 5.8
void setDesktopSizeTo5P8() {
  setDesktopWindowSize(const Size(375, 812));
  setDesktopMinWindowSize(const Size(375, 812));
  setDesktopMaxWindowSize(const Size(375, 812));
}

/// set desktop size to iphone 6.1
Future<void> setDesktopSizeTo6P1() async {
  setDesktopWindowSize(const Size(414, 896));
  await setDesktopMinWindowSize(const Size(414, 896));
  await setDesktopMaxWindowSize(const Size(414, 896));
}
