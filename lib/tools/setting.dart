import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/tools/internal.dart';

/// 安装apk  仅支持android
/// Installing APK only supports Android
enum InstallResult {
  /// 安装成功
  success,

  /// 取消安装
  cancel,

  /// 没有打开安装权限
  notPermissions,

  /// 出现错误
  error
}

Future<InstallResult?> installApp(String apkPath) async {
  if (!isAndroid) return null;
  final String? result =
      await curiosityChannel.invokeMethod('installApp', apkPath);
  switch (result) {
    case 'success':
      return InstallResult.success;
    case 'not permissions':
      return InstallResult.notPermissions;
    case 'cancel':
      return InstallResult.cancel;
  }
  return InstallResult.error;
}

/// ios str 对应app id
/// macOS str 对应app id
/// android str 对应 packageName，安装多个应用商店时会弹窗选择, marketPackageName 指定打开应用市场的包名
Future<bool> openAppStore(String str, {String? marketPackageName}) async {
  if (isIOS || isMacOS) {
    final String url = 'itms-apps://itunes.apple.com/us/app/$str';
    if (await canOpenUrl(url)) {
      return await openUrl(url);
    } else {
      return false;
    }
  } else if (isAndroid) {
    final bool? data = await curiosityChannel.invokeMethod<bool>(
        'openAppMarket', <String, String>{
      'packageName': str,
      'marketPackageName': marketPackageName ?? ''
    });
    return data ?? false;
  }
  return false;
}

/// 是否安装某个app
/// Android str 对应包名
/// ios str 对应 url schemes
Future<bool> isInstallApp(String str) async {
  if (isIOS || isMacOS) {
    return await canOpenUrl(str);
  } else if (isAndroid) {
    final bool? data =
        await curiosityChannel.invokeMethod<bool?>('isInstallApp', str);
    return data ?? false;
  }
  return false;
}

/// 判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
Future<bool> getGPSStatus() async {
  if (!supportPlatform) return false;
  final bool? state = await curiosityChannel.invokeMethod('getGPSStatus');
  return state ?? false;
}

/// 跳转到系统设置页面
/// settingType 仅对android 有效
Future<bool> openSystemSetting([SettingType? settingType]) async {
  if (!supportPlatformMobile) return false;
  if (isIOS) {
    final bool? state = await curiosityChannel.invokeMethod('openAppSetting');
    return state ?? false;
  }
  if (isAndroid) {
    final List<String> type =
        (settingType ?? SettingType.setting).toString().split('.');
    final bool? state =
        await curiosityChannel.invokeMethod('openSystemSetting', type[1]);
    return state ?? false;
  }
  return false;
}

/// Exit app
Future<void> exitApp() async {
  if (!supportPlatform) return;
  return await curiosityChannel.invokeMethod<dynamic>('exitApp');
}
