import 'dart:typed_data';

import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/tools/internal.dart';

/// 系统分享
Future<String?> openSystemShare(
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
  return await curiosityChannel
      .invokeMethod('openSystemShare', <String, dynamic>{
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
Future<String?> openSystemGallery() async {
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
  String? path =
      await curiosityChannel.invokeMethod('openSystemCamera', savePath);
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
