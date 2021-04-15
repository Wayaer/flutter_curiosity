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
  return await curiosityChannel.invokeMethod('setWindowSize',
      <String, double>{'width': size.width, 'height': size.height});
}

Future<void> setDesktopMinWindowSize(Size size) async {
  if (!supportPlatformDesktop) return;
  return await curiosityChannel.invokeMethod('setMinWindowSize',
      <String, double>{'width': size.width, 'height': size.height});
}

Future<void> setDesktopMaxWindowSize(Size size) async {
  if (!supportPlatformDesktop) return;
  return await curiosityChannel.invokeMethod('setMaxWindowSize',
      <String, double>{'width': size.width, 'height': size.height});
}

Future<void> resetDesktopMaxWindowSize() async {
  if (!supportPlatformDesktop) return;
  return await curiosityChannel.invokeMethod('resetMaxWindowSize');
}

Future<void> toggleDesktopFullScreen() async {
  if (!supportPlatformDesktop) return;
  return await curiosityChannel.invokeMethod('toggleFullScreen');
}

Future<void> setDesktopFullScreen(bool fullscreen) => curiosityChannel
    .invokeMethod('setFullScreen', <String, bool>{'fullscreen': fullscreen});

Future<bool?> getDesktopFullScreen() async {
  if (!supportPlatformDesktop) return null;
  final bool? fullscreen =
      await curiosityChannel.invokeMethod<bool?>('getFullScreen');
  print(fullscreen);
  if (fullscreen is bool) return fullscreen;
  return null;
}

/// set desktop size to iphone 4.7
Future<void> setDesktopSizeTo4P7() async {
  await setDesktopMinWindowSize(const Size(374, 666));
  await setDesktopMaxWindowSize(const Size(375, 667));
}

/// set desktop size to iphone 5.5
Future<void> setDesktopSizeTo5P5() async {
  await setDesktopMinWindowSize(const Size(413, 735));
  await setDesktopMaxWindowSize(const Size(414, 736));
}

/// set desktop size to iphone 5.8
Future<void> setDesktopSizeTo5P8() async {
  await setDesktopMinWindowSize(const Size(374, 811));
  await setDesktopMaxWindowSize(const Size(375, 812));
}

/// set desktop size to iphone 6.1
Future<void> setDesktopSizeTo6P1() async {
  await setDesktopMinWindowSize(const Size(413, 895));
  await setDesktopMaxWindowSize(const Size(414, 896));
}
