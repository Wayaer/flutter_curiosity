import 'dart:io';

import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/src/tools/internal.dart';

class AppInfo {
  static Future<AppInfoModel> getPackageInfo() async {
    if (InternalTools.supportPlatform()) return null;
    Map<String, dynamic> map = await curiosityChannel.invokeMapMethod<String, dynamic>('getAppInfo');
    return AppInfoModel.fromJson(map);
  }

  ///android versionCode  ios version
  static Future<int> getVersionCode() async {
    AppInfoModel appInfoModel = await getPackageInfo();
    return appInfoModel.versionCode;
  }

  static Future<String> getAppName() async {
    if (Platform.isIOS || Platform.isAndroid) {
      AppInfoModel appInfoModel = await getPackageInfo();
      return appInfoModel.appName;
    }
    return null;
  }

  static Future<String> getPackageName() async {
    AppInfoModel appInfoModel = await getPackageInfo();
    return appInfoModel.packageName;
  }

  ///android versionName  ios buildName
  static Future<String> getVersionName() async {
    AppInfoModel appInfoModel = await getPackageInfo();
    return appInfoModel.versionName;
  }

  ///获取根目录
  static Future<String> getRootDirectory() async {
    AppInfoModel appInfoModel = await getPackageInfo();
    return Platform.isAndroid ? appInfoModel.externalStorageDirectory : appInfoModel.homeDirectory;
  }
}
