import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/tools/internal.dart';

/// 判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
/// Judge whether GPS is on. If GPS or AGPs is turned on, it is considered to be on
Future<bool?> get getGPSStatus async {
  if (!supportPlatformMobile) return null;
  return await curiosityChannel.invokeMethod('getGPSStatus');
}

/// 跳转到GPS定位权限设置页面
/// Jump to the GPS location permission setting page
Future<bool?> get jumpGPSSetting async {
  if (!supportPlatformMobile) return null;
  if (isIOS) return await jumpAppSetting;
  if (isAndroid) return await curiosityChannel.invokeMethod('jumpGPSSetting');
  return null;
}

/// 跳转到App权限设置页面
/// Jump to app permission setting page
Future<bool?> get jumpAppSetting async {
  if (!supportPlatformMobile) return null;
  return await curiosityChannel.invokeMethod('jumpAppSetting');
}

/// 跳转到android 系统设置
/// Jump to Android system settings
Future<bool?> jumpSystemSetting({SettingType? settingType}) async {
  if (!supportPlatformMobile) return null;
  if (isIOS) return await jumpAppSetting;
  if (isAndroid) {
    final List<String> type =
        (settingType ?? SettingType.setting).toString().split('.');
    return await curiosityChannel.invokeMethod(
        'jumpSystemSetting', <String, String>{'settingType': type[1]});
  }
  return null;
}
