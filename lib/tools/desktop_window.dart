import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_curiosity/constant/constant.dart';
import 'package:flutter_curiosity/tools/internal.dart';

Future<Size?> getDesktopWindowSize() async {
  if (!supportPlatformDesktop) return null;
  final List<dynamic>? arr =
  await curiosityChannel.invokeMethod<List<dynamic>?>('getWindowSize');
  if (arr != null && arr is List && arr.length == 2)
    return Size(arr[0] as double, arr[1] as double);
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

Future<void> setDesktopFullScreen(bool fullscreen) =>
    curiosityChannel
        .invokeMethod(
        'setFullScreen', <String, bool>{'fullscreen': fullscreen});

Future<bool?> getDesktopFullScreen() async {
  if (!supportPlatformDesktop) return null;
  final bool? fullscreen =
  await curiosityChannel.invokeMethod<bool?>('getFullScreen');
  if (fullscreen is bool) return fullscreen;
  return null;
}
