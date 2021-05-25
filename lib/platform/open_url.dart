import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_curiosity/constant/constant.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/tools/internal.dart';

Future<bool> openUrl(
  String url, {
  Brightness? statusBarBrightness,

  /// macos
  bool universalLinksOnly = false,

  /// android
  Map<String, String> headers = const <String, String>{},
}) async {
  if (!supportPlatform) return false;
  bool previousAutomaticSystemUiAdjustment = true;
  if (statusBarBrightness != null && isIOS && WidgetsBinding.instance != null) {
    previousAutomaticSystemUiAdjustment =
        WidgetsBinding.instance!.renderView.automaticSystemUiAdjustment;
    WidgetsBinding.instance!.renderView.automaticSystemUiAdjustment = false;
    SystemChrome.setSystemUIOverlayStyle(statusBarBrightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light);
  }

  final bool? result =
      await curiosityChannel.invokeMethod<bool?>('openUrl', <String, Object>{
    'url': url,
    'universalLinksOnly': universalLinksOnly,
    'headers': headers,
  });

  if (statusBarBrightness != null && WidgetsBinding.instance != null) {
    WidgetsBinding.instance!.renderView.automaticSystemUiAdjustment =
        previousAutomaticSystemUiAdjustment;
  }
  return result ?? false;
}

Future<bool> canOpenUrl(String url) async {
  if (!supportPlatform) return false;
  final bool? state = await curiosityChannel.invokeMethod('canOpenUrl', url);
  return state ?? false;
}
