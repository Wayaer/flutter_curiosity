import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/tools/internal.dart';

/// get Android Device Info
Future<AndroidDeviceModel?> get getAndroidDeviceInfo async {
  if (!supportPlatform) return null;
  if (!isAndroid) return null;
  final Map<String, dynamic> map = (await curiosityChannel
      .invokeMapMethod<String, dynamic>('getDeviceInfo'))!;
  return AndroidDeviceModel.fromJson(map);
}

/// get IOS Device Info
Future<IOSDeviceModel?> get getIOSDeviceInfo async {
  if (!supportPlatform) return null;
  if (!isIOS) return null;
  final Map<String, dynamic> map = (await curiosityChannel
      .invokeMapMethod<String, dynamic>('getDeviceInfo'))!;
  return IOSDeviceModel.fromJson(map);
}

/// get all info
Future<AppInfoModel?> get getPackageInfo async {
  if (!supportPlatform) return null;
  final Map<String, dynamic> map =
      (await curiosityChannel.invokeMapMethod<String, dynamic>('getAppInfo'))!;
  return AppInfoModel.fromJson(map);
}

/// android versionCode  ios version
Future<int?> get getVersionCode async {
  if (!supportPlatform) return null;
  final AppInfoModel appInfoModel = (await getPackageInfo)!;
  return appInfoModel.versionCode;
}

/// app name
Future<String?> get getAppName async {
  if (!supportPlatform) return null;
  if (!(isIOS || isAndroid)) return null;
  final AppInfoModel appInfoModel = (await getPackageInfo)!;
  return appInfoModel.appName;
}

/// package name
Future<String?> get getPackageName async {
  if (!supportPlatform) return null;
  final AppInfoModel appInfoModel = (await getPackageInfo)!;
  return appInfoModel.packageName;
}

/// android versionName  ios buildName
Future<String?> get getVersionName async {
  if (!supportPlatform) return null;
  final AppInfoModel appInfoModel = (await getPackageInfo)!;
  return appInfoModel.versionName;
}

/// root directory
Future<String?> get getRootDirectory async {
  if (!supportPlatform) return null;
  final AppInfoModel appInfoModel = (await getPackageInfo)!;
  if (isAndroid) return appInfoModel.externalStorageDirectory;
  if (isIOS || isMacOS) return appInfoModel.homeDirectory;
  return '';
}

/// AppInfo
Future<List<AppsModel>?> get getInstalledApp async {
  if (!supportPlatform) return null;
  if (!isAndroid) return null;
  final List<Map<dynamic, dynamic>> appList = (await curiosityChannel
      .invokeListMethod<Map<dynamic, dynamic>>('getInstalledApp'))!;
  if (appList is! List) return null;
  final List<AppsModel> list = <AppsModel>[];
  for (final dynamic data in appList) {
    list.add(AppsModel.fromJson(data as Map<dynamic, dynamic>));
  }
  return list;
}
