import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/src/tools/internal.dart';

class AppInfo {
  ///get all info
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

  ///app name
  static Future<String> getAppName() async {
    if (InternalTools.isIOS() || InternalTools.isAndroid()) {
      AppInfoModel appInfoModel = await getPackageInfo();
      return appInfoModel.appName;
    }
    return null;
  }

  ///package name
  static Future<String> getPackageName() async {
    AppInfoModel appInfoModel = await getPackageInfo();
    return appInfoModel.packageName;
  }

  ///android versionName  ios buildName
  static Future<String> getVersionName() async {
    AppInfoModel appInfoModel = await getPackageInfo();
    return appInfoModel.versionName;
  }

  ///root directory
  static Future<String> getRootDirectory() async {
    AppInfoModel appInfoModel = await getPackageInfo();
    if (InternalTools.isAndroid()) return appInfoModel.externalStorageDirectory;
    if (InternalTools.isIOS() || InternalTools.isMacOS()) return appInfoModel.homeDirectory;
    return '';
  }
}
