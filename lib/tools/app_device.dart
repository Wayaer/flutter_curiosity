import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/tools/internal.dart';

/// get Android/IOS Device Info
Future<DeviceInfoModel?> getDeviceInfo() async {
  if (!supportPlatform) return null;
  if (!isIOS) return null;
  final Map<String, dynamic>? map =
      await curiosityChannel.invokeMapMethod<String, dynamic>('getDeviceInfo');
  if (map != null) return DeviceInfoModel.fromJson(map);
  return null;
}

/// get app path
Future<AppPathModel?> getAppPath() async {
  if (!supportPlatform) return null;
  final Map<String, dynamic>? map =
      await curiosityChannel.invokeMapMethod<String, dynamic>('getAppPath');
  if (map != null) return AppPathModel.fromJson(map);
  return null;
}

/// get App info
Future<AppInfoModel?> getAppInfo() async {
  if (!supportPlatform) return null;
  final Map<String, dynamic>? map =
      await curiosityChannel.invokeMapMethod<String, dynamic>('getAppInfo');
  if (map != null) return AppInfoModel.fromJson(map);
  return null;
}

/// get Android  installed apps
Future<List<AppsModel>> getInstalledApp() async {
  if (!isAndroid) return <AppsModel>[];
  final List<Map<dynamic, dynamic>>? appList = await curiosityChannel
      .invokeListMethod<Map<dynamic, dynamic>>('getInstalledApp');
  final List<AppsModel> list = <AppsModel>[];
  if (appList != null && appList is List) {
    for (final dynamic data in appList) {
      list.add(AppsModel.fromJson(data as Map<dynamic, dynamic>));
    }
  }
  return list;
}
