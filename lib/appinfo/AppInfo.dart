import 'dart:io';


import 'package:flutter_curiosity/appinfo/AppInfoModel.dart';
import 'package:flutter_curiosity/constant/Constant.dart';

class PackageInfo {

  static Future<AppInfoModel> getPackageInfo() async {
    Map<String, dynamic> map =
    await channel.invokeMapMethod<String, dynamic>('getAppInfo');
    return AppInfoModel.fromJson(map);
  }

  static getVersionCode() async {
    if (Platform.isIOS || Platform.isAndroid) {
      AppInfoModel appInfoModel = await getPackageInfo();
      return appInfoModel.versionCode;
    }
  }

  static getAppName() async {
    if (Platform.isIOS || Platform.isAndroid) {
      AppInfoModel appInfoModel = await getPackageInfo();
      return appInfoModel.appName;
    }
  }

  static getPackageName() async {
    if (Platform.isIOS || Platform.isAndroid) {
      AppInfoModel appInfoModel = await getPackageInfo();
      return appInfoModel.packageName;
    }
  }

  static getVersionName() async {
    if (Platform.isIOS || Platform.isAndroid) {
      AppInfoModel appInfoModel = await getPackageInfo();
      return appInfoModel.versionName;
    }
  }

/// The app name. `CFBundleDisplayName` on iOS, `application/label` on Android.
/// The package name. `bundleIdentifier` on iOS, `getPackageName` on Android.
/// The package version. `CFBundleShortVersionString` on iOS, `versionName` on Android.
/// The build number. `CFBundleVersion` on iOS, `versionCode` on Android.
}
