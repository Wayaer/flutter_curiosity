import 'package:flutter/services.dart';
import 'package:flutter_curiosity/constant/constant.dart';
import 'package:flutter_curiosity/platform/platform.dart';
import 'package:flutter_curiosity/tools/internal.dart';

typedef EventHandlerActivityResult = void Function(
    AndroidActivityResult result);

typedef EventHandlerRequestPermissionsResult = void Function(
    AndroidRequestPermissionsResult result);

class AndroidActivityResult {
  AndroidActivityResult.formJson(Map<dynamic, dynamic> json) {
    requestCode = json['requestCode'] as int;
    resultCode = json['resultCode'] as int;
    data = json['data'] as dynamic;
    extras = json['extras'] as dynamic;
  }

  late int requestCode;
  late int resultCode;
  dynamic data;
  dynamic extras;
}

class AndroidRequestPermissionsResult {
  AndroidRequestPermissionsResult.formJson(Map<dynamic, dynamic> json) {
    requestCode = (json['requestCode'] as int?) ?? 0;
    final List<dynamic> _permissions = json['permissions'] as List<dynamic>;
    permissions = _permissions.map((dynamic e) => e as String).toList();
    final List<dynamic> _grantResults = json['grantResults'] as List<dynamic>;
    grantResults = _grantResults.map((dynamic e) => e as int).toList();
  }

  late int requestCode;
  late List<String> permissions;
  late List<int> grantResults;
}

/// android
/// onActivityResult 监听
/// onRequestPermissionsResult 监听
Future<void> onResultListener({
  EventHandlerActivityResult? activityResult,
  EventHandlerRequestPermissionsResult? requestPermissionsResult,
}) async {
  if (!supportPlatformMobile) return;
  if (isAndroid) {
    if (activityResult != null)
      await curiosityChannel.invokeMethod<dynamic>('onActivityResult');

    if (requestPermissionsResult != null)
      await curiosityChannel
          .invokeMethod<dynamic>('onRequestPermissionsResult');
  }
  curiosityChannel.setMethodCallHandler((MethodCall call) async {
    final Map<dynamic, dynamic> argument =
        call.arguments as Map<dynamic, dynamic>;
    switch (call.method) {
      case 'onActivityResult':
        if (activityResult != null)
          activityResult(AndroidActivityResult.formJson(argument));
        break;
      case 'onRequestPermissionsResult':
        if (requestPermissionsResult != null)
          requestPermissionsResult(
              AndroidRequestPermissionsResult.formJson(argument));
        break;
    }
  });
}
