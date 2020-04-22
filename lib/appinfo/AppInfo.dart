import 'dart:io';

import 'package:flutter_curiosity/appinfo/AppInfoModel.dart';
import 'package:flutter_curiosity/constant/Constant.dart';
import 'package:flutter_curiosity/tools/Tools.dart';

class AppInfo {
  static Future<AppInfoModel> getPackageInfo() async {
    Map<String, dynamic> map = await methodChannel.invokeMapMethod<String, dynamic>('getAppInfo');
    return AppInfoModel.fromJson(map);
  }

  //android versionCode  ios version
  static Future<int> getVersionCode() async {
    Tools.supportPlatform();
    AppInfoModel appInfoModel = await getPackageInfo();
    return appInfoModel.versionCode;
  }

  static Future<String> getAppName() async {
    Tools.supportPlatform();
    if (Platform.isIOS || Platform.isAndroid) {
      AppInfoModel appInfoModel = await getPackageInfo();
      return appInfoModel.appName;
    }
  }

  static Future<String> getPackageName() async {
    Tools.supportPlatform();
    AppInfoModel appInfoModel = await getPackageInfo();
    return appInfoModel.packageName;
  }

  //android versionName  ios buildName
  static Future<String> getVersionName() async {
    Tools.supportPlatform();
    AppInfoModel appInfoModel = await getPackageInfo();
    return appInfoModel.versionName;
  }

  //获取根目录
  static Future<String> getRootDirectory() async {
    Tools.supportPlatform();
    AppInfoModel appInfoModel = await getPackageInfo();
    return Platform.isAndroid ? appInfoModel.externalStorageDirectory : appInfoModel.homeDirectory;
  }

  //目录下所有文件夹以及文件名字  isAbsolutePath true 目录下文件的完整路径
  static Future<List<String>> getDirectoryAllName(String path, {bool isAbsolutePath: false}) async {
    Tools.supportPlatform();
    List<String> pathNameList =
    await methodChannel.invokeListMethod('getDirectoryAllName', {'path': path, 'isAbsolutePath': isAbsolutePath});
    if (Platform.isIOS && isAbsolutePath) {
      List<String> list = List();
      if (pathNameList.length > 0) {
        pathNameList.map((value) {
          list.add(path + '/' + value);
        }).toList();
        return list;
      }
    }
    return pathNameList;
  }

/// The app name. `CFBundleDisplayName` on iOS, `application/label` on Android.
/// The package name. `bundleIdentifier` on iOS, `getPackageName` on Android.
/// The package version. `CFBundleShortVersionString` on iOS, `versionName` on Android.
/// The build number. `CFBundleVersion` on iOS, `versionCode` on Android.
}
