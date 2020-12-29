import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/tools/internal.dart';

bool get isAndroid => Platform.isAndroid;

bool get isIOS => Platform.isIOS;

bool get isMacOS => Platform.isMacOS;

bool get isWindows => Platform.isWindows;

bool get isLinux => Platform.isLinux;

bool get isFuchsia => Platform.isFuchsia;

bool get isMobile => Platform.isIOS || Platform.isAndroid;

bool get isDesktop =>
    Platform.isMacOS || Platform.isWindows || Platform.isLinux;

/// 安装apk  仅支持android
/// Installing APK only supports Android
/// success  安装成功
/// cancel  取消安装
/// not permissions  没有打开安装权限
Future<String> installApp(String apkPath) async {
  if (!isAndroid) return null;
  return await curiosityChannel
      .invokeMethod('installApp', <String, String>{'apkPath': apkPath});
}

/// 去应用市场 android 安装多个应用商店时会弹窗选择，ios app store
/// When you go to the app market and install multiple app stores, you will pop up to select IOS app store
/// android => packageName
/// ios => app id
/// The android platform "marketPackageName" cannot be null
Future<void> goToMarket<T>(
    {String packageName, String marketPackageName, String appID}) async {
  if (!_supportPlatform()) {
    if (isIOS) {
      assert(appID != null);
      await curiosityChannel
          .invokeMethod<T>('goToMarket', <String, String>{'appId': appID});
    }
    if (isAndroid) {
      assert(packageName != null && marketPackageName != null);
      if (marketPackageName == null)
        await curiosityChannel.invokeMethod<T>('goToMarket', <String, String>{
          'packageName': packageName,
          'marketPackageName': marketPackageName
        });
    }
  }
}

/// 是否安装某个app  仅支持android
/// is install an app that only supports Android
Future<bool> isInstallApp(String packageName) async {
  if (isAndroid) return false;
  return await curiosityChannel.invokeMethod(
      'isInstallApp', <String, String>{'packageName': packageName});
}

/// 退出app
/// Exit app
Future<void> get exitApp async {
  if (!_supportPlatform())
    await curiosityChannel.invokeMethod<dynamic>('exitApp');
}

/// 获取文件夹或文件大小
/// Gets the folder or file size
Future<String> getFilePathSize(String path) async {
  if (_supportPlatform()) return null;
  return await curiosityChannel
      .invokeMethod('getFilePathSize', <String, String>{'filePath': path});
}

/// 拨打电话
/// directDial true 直接拨打电话 false 跳转到拨号页面并输入手机号
/// directDial 为 true 需要 自行申请动态申请权限
Future<void> systemCallPhone<T>(String phoneNumber,
    {bool directDial = false}) async {
  if (_supportPlatform()) return;
  await curiosityChannel.invokeMethod<T>('callPhone',
      <String, dynamic>{'phoneNumber': phoneNumber, 'directDial': directDial});
}

/// 系统分享
Future<String> systemShare(
    {String title = 'Share',
    String content,
    List<String> imagesPath,
    ShareType shareType}) async {
  if (_supportPlatform()) return 'not support ${Platform.operatingSystem}';
  if (shareType == null) return 'The shareType cannot be empty';

  if (shareType == ShareType.images) {
    if (imagesPath == null || imagesPath.isEmpty)
      return 'The shareType cannot be empty';
  }
  if (content == null && imagesPath == null)
    return 'A share parameter must be passed content or imagesPath';
  if (content != null && imagesPath != null)
    return 'Only one parameter can be passed';
  return await curiosityChannel.invokeMethod('systemShare', <String, dynamic>{
    'title': title,
    'content': content,
    'type': shareType.toString().split('.')[1],
    'imagesPath': imagesPath
  });
}

/// 判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
/// Judge whether GPS is on. If GPS or AGPs is turned on, it is considered to be on
Future<bool> get getGPSStatus async {
  if (_supportPlatform()) return null;
  return await curiosityChannel.invokeMethod('getGPSStatus');
}

/// 跳转到GPS定位权限设置页面
/// Jump to the GPS location permission setting page
Future<bool> get jumpGPSSetting async {
  if (_supportPlatform()) return null;
  if (isIOS) return await jumpAppSetting;
  if (isAndroid) return await curiosityChannel.invokeMethod('jumpGPSSetting');
  return null;
}

/// 跳转到App权限设置页面
/// Jump to app permission setting page
Future<bool> get jumpAppSetting async {
  if (_supportPlatform()) return null;
  return await curiosityChannel.invokeMethod('jumpAppSetting');
}

/// 跳转到android 系统设置
/// Jump to Android system settings
Future<bool> jumpSystemSetting({SettingType settingType}) async {
  if (_supportPlatform()) return null;
  if (isIOS) return await jumpAppSetting;
  if (isAndroid) {
    final List<String> type = settingType.toString().split('.');
    return await curiosityChannel.invokeMethod(
        'jumpSystemSetting', <String, String>{'settingType': type[1]});
  }
  return null;
}

/// 打开系统相册
/// 返回文件路径
/// ios info.plist add
///       <key>NSPhotoLibraryUsageDescription</key>
///       <string>是否允许Curiosity访问你的相册？</string>
/// ios path 包含 file:///
Future<String> get openSystemGallery async {
  if (_supportPlatform()) return null;
  return await curiosityChannel.invokeMethod('openSystemGallery');
}

/// 打开系统相机
/// 返回文件路径
/// Android AndroidManifest.xml 添加以下内容
/// <application
///          ...>
///   <provider
///            android:name="androidx.core.content.FileProvider"
///            android:authorities="${applicationId}.fileprovider"
///            android:exported="false"
///            android:grantUriPermissions="true">
///            <meta-data
///                android:name="android.support.FILE_PROVIDER_PATHS"
///                android:resource="@xml/file_paths" />
///   </provider>
/// </application>
/// ios info.plist add
///     <key>NSCameraUsageDescription</key>
///       <string>是否允许APP使用你的相机？</string>
///      <key>NSPhotoLibraryUsageDescription</key>
///       <string>是否允许APP访问你的相册？</string>
/// ios path 包含 file:///
Future<String> openSystemCamera({String savePath}) async {
  /// savePath => android 图片临时储存位置 (仅支持android)
  /// alertNativeTips => ios 是否弹出用户未允许访问相机权限提示 (仅支持ios)
  if (_supportPlatform()) return null;
  String path = await curiosityChannel
      .invokeMethod('openSystemCamera', <String, String>{'path': savePath});
  if (savePath != null) path = savePath;
  return path;
}

/// save image to Gallery
/// imageBytes can't null
@deprecated
Future<String> saveImageToGallery(Uint8List imageBytes,
    {int quality = 100, String name}) async {
  assert(imageBytes != null);
  final String result = await curiosityChannel.invokeMethod(
      'saveImageToGallery', <String, dynamic>{
    'imageBytes': imageBytes,
    'quality': quality,
    'name': name
  });
  return result;
}

/// Save the PNG，JPG，JPEG image or video located at [file]
/// to the local device media gallery.
@deprecated
Future<String> saveFileToGallery(String file) async {
  assert(file != null);
  final String result =
      await curiosityChannel.invokeMethod('saveFileToGallery', file);
  return result;
}

/// AppInfo
Future<List<AppsModel>> get getInstalledApp async {
  if (!isAndroid) return null;
  final List<Map<dynamic, dynamic>> appList = await curiosityChannel
      .invokeListMethod<Map<dynamic, dynamic>>('getInstalledApp');
  if (appList is! List) return null;
  final List<AppsModel> list = <AppsModel>[];
  for (final dynamic data in appList) {
    list.add(AppsModel.fromJson(data as Map<dynamic, dynamic>));
  }
  return list;
}

/// get Android Device Info
Future<AndroidDeviceModel> get getAndroidDeviceInfo async {
  if (!isAndroid) return null;
  final Map<String, dynamic> map =
      await curiosityChannel.invokeMapMethod<String, dynamic>('getDeviceInfo');
  return AndroidDeviceModel.fromJson(map);
}

/// get IOS Device Info
Future<IOSDeviceModel> get getIOSDeviceInfo async {
  if (!isIOS) return null;
  final Map<String, dynamic> map =
      await curiosityChannel.invokeMapMethod<String, dynamic>('getDeviceInfo');
  return IOSDeviceModel.fromJson(map);
}

/// get all info
Future<AppInfoModel> get getPackageInfo async {
  if (_supportPlatform()) return null;
  final Map<String, dynamic> map =
      await curiosityChannel.invokeMapMethod<String, dynamic>('getAppInfo');
  return AppInfoModel.fromJson(map);
}

/// android versionCode  ios version
Future<int> get getVersionCode async {
  final AppInfoModel appInfoModel = await getPackageInfo;
  return appInfoModel.versionCode;
}

/// app name
Future<String> get getAppName async {
  if (isIOS || isAndroid) {
    final AppInfoModel appInfoModel = await getPackageInfo;
    return appInfoModel.appName;
  }
  return null;
}

/// package name
Future<String> get getPackageName async {
  final AppInfoModel appInfoModel = await getPackageInfo;
  return appInfoModel.packageName;
}

/// android versionName  ios buildName
Future<String> get getVersionName async {
  final AppInfoModel appInfoModel = await getPackageInfo;
  return appInfoModel.versionName;
}

/// root directory
Future<String> get getRootDirectory async {
  final AppInfoModel appInfoModel = await getPackageInfo;
  if (isAndroid) return appInfoModel.externalStorageDirectory;
  if (isIOS || isMacOS) return appInfoModel.homeDirectory;
  return '';
}

bool _supportPlatform() {
  if (!(isAndroid || isIOS || isMacOS)) {
    log('Curiosity is not support ${Platform.operatingSystem}');
    return true;
  }
  return false;
}
