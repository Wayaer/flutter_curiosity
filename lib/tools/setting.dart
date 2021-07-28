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

/// android  packageName，安装多个应用商店时会弹窗选择, marketPackageName 指定打开应用市场的包名
Future<bool> openAndroidAppMarket(String packageName,
    {String? marketPackageName}) async {
  if (!isAndroid) return false;
  bool? state = false;
  try {
    if (marketPackageName != null) {
      state = await isInstallAppWithAndroid(marketPackageName);
      if (!state) return state;
    }
    state = await curiosityChannel.invokeMethod<bool>(
        'openAppMarket', <String, String>{
      'packageName': packageName,
      'marketPackageName': marketPackageName ?? ''
    });
  } catch (e) {
    state = false;
  }
  return state ?? false;
}

/// 是否安装某个app
/// Android packageName 对应包名
Future<bool> isInstallAppWithAndroid(String packageName) async {
  if (!isAndroid) return false;
  final bool? data =
      await curiosityChannel.invokeMethod<bool?>('isInstallApp', packageName);
  return data ?? false;
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
  if (isMobile) {
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
