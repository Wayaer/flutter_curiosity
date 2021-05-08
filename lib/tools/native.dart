import 'dart:typed_data';

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
  final String? result = await curiosityChannel
      .invokeMethod('installApp', <String, String>{'apkPath': apkPath});
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

/// 去应用市场 android 安装多个应用商店时会弹窗选择
/// When you go to the app market and install multiple app stores
/// android => packageName
/// The android platform "marketPackageName" cannot be null
Future<bool> openAndroidMarket(
    {required String packageName, String? marketPackageName}) async {
  if (!isAndroid) return false;
  if (marketPackageName != null) {
    final bool isInstall = await isInstallApp(marketPackageName);
    if (!isInstall) return false;
  }
  final bool? data = await curiosityChannel.invokeMethod<bool>(
      'openAppMarket', <String, String>{
    'packageName': packageName,
    'marketPackageName': marketPackageName ?? ''
  });
  return data ?? false;
}

/// 是否安装某个app  仅支持android
/// is install an app that only supports Android
Future<bool> isInstallApp(String packageName) async {
  if (!isAndroid) return false;
  final bool? data =
      await curiosityChannel.invokeMethod<bool?>('isInstallApp', packageName);
  return data ?? false;
}

/// 退出app
/// Exit app
Future<void> get exitApp async {
  if (!supportPlatform) return;
  await curiosityChannel.invokeMethod<dynamic>('exitApp');
}

/// 获取文件夹或文件大小
/// Gets the folder or file size
Future<String?> getFilePathSize(String path) async {
  if (!supportPlatform) return null;
  return await curiosityChannel
      .invokeMethod('getFilePathSize', <String, String>{'filePath': path});
}

/// 拨打电话
/// directDial true 直接拨打电话 false 跳转到拨号页面并输入手机号
/// directDial 为 true 需要 自行申请动态申请权限
Future<bool> systemCallPhone<T>(String phoneNumber,
    {bool directDial = false}) async {
  if (!supportPlatform) return;
  await curiosityChannel.invokeMethod<bool>('callPhone',
      <String, dynamic>{'phoneNumber': phoneNumber, 'directDial': directDial});
}

/// 系统分享
Future<String?> systemShare(
    {String title = 'Share',
    String? content,
    List<String>? imagesPath,
    required ShareType shareType}) async {
  if (!supportPlatformMobile) return 'not support Platform';
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

/// 打开系统相册
/// 返回文件路径
/// ios info.plist add
///       <key>NSPhotoLibraryUsageDescription</key>
///       <string>是否允许Curiosity访问你的相册？</string>
/// ios path 包含 file:///
Future<String?> get openSystemGallery async {
  if (!supportPlatformMobile) return null;
  return await curiosityChannel.invokeMethod('openSystemGallery');
}

/// 打开系统相机
/// 返回文件路径
/// Android AndroidManifest.xml 添加以下内容
/// ios info.plist add
///     <key>NSCameraUsageDescription</key>
///       <string>是否允许APP使用你的相机？</string>
///      <key>NSPhotoLibraryUsageDescription</key>
///       <string>是否允许APP访问你的相册？</string>
/// ios path 包含 file:///
Future<String?> openSystemCamera({String? savePath}) async {
  /// savePath => android 图片临时储存位置 (仅支持android)
  if (!supportPlatformMobile) return null;
  Map<String, String>? arguments;
  if (savePath != null) arguments = <String, String>{'path': savePath};
  String? path =
      await curiosityChannel.invokeMethod('openSystemCamera', arguments);
  if (savePath != null) path = savePath;
  return path;
}

/// save image to Gallery
/// imageBytes can't null
Future<String?> saveImageToGallery(Uint8List imageBytes,
    {int quality = 100, String? name}) async {
  if (!supportPlatformMobile) return null;
  return await curiosityChannel.invokeMethod(
      'saveImageToGallery', <String, dynamic>{
    'imageBytes': imageBytes,
    'quality': quality,
    'name': name
  });
}

/// Save the PNG，JPG，JPEG image or video located at [file]
/// to the local device media gallery.
Future<String?> saveFileToGallery(String file) async {
  if (!supportPlatformMobile) return null;
  return await curiosityChannel.invokeMethod('saveFileToGallery', file);
}
