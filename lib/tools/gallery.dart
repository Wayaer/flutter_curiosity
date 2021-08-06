import 'dart:typed_data';

import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/tools/internal.dart';

class GalleryOptions {
  GalleryOptions(
      {this.allowsEditing = false,
      this.flashMode = FlashMode.off,
      this.savePath,
      this.isFront = false,
      this.hasSound = true,
      this.videoMaximumDuration = 15,
      this.qualityType = QualityType.medium,
      this.cameraMode = CameraMode.photo});

  ////****** android 配置信息 (仅支持android)  ******////
  /// savePath =>  图片临时储存位置
  String? savePath;

  ////****** ios 配置信息 (仅支持ios) ******////
  /// 是否可编辑
  bool allowsEditing;

  /// 闪光灯模式
  FlashMode flashMode;

  /// 是否使用前置摄像头
  bool isFront;

  /// 视频是否包含声音
  bool hasSound;

  /// 录像的最大时间
  double videoMaximumDuration;

  /// 视频质量
  QualityType qualityType;

  /// 相机模式
  CameraMode cameraMode;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'allowsEditing': allowsEditing,
        'hasSound': hasSound,
        'isFront': isFront,
        'savePath': savePath,
        'videoMaximumDuration': videoMaximumDuration,
        'flashMode': FlashMode.values.indexOf(flashMode),
        'qualityType': QualityType.values.indexOf(qualityType),
        'cameraMode': CameraMode.values.indexOf(cameraMode),
      };
}

/// 视频质量
enum QualityType { high, medium, low, p640x480, p1280x720, p960x540 }

/// 闪光灯模式
enum FlashMode { auto, on, off }
enum CameraMode {
  /// 拍照
  photo,

  /// 视频
  video,
}

/// 打开系统相册
/// 返回文件路径
/// ios info.plist add
///       <key>NSPhotoLibraryUsageDescription</key>
///       <string>是否允许Curiosity访问你的相册？</string>
/// ios path
Future<String?> openSystemGallery({GalleryOptions? options}) async {
  if (!supportPlatformMobile) return null;
  options ??= GalleryOptions();
  final String? path =
      await curiosityChannel.invokeMethod('openSystemGallery', options.toMap());
  return path;
}

/// 打开系统相机
/// 返回文件路径
/// Android AndroidManifest.xml 添加以下内容
/// ios info.plist add
///     <key>NSCameraUsageDescription</key>
///       <string>是否允许APP使用你的相机？</string>
///      <key>NSPhotoLibraryUsageDescription</key>
///       <string>是否允许APP访问你的相册？</string>
/// ios path
Future<String?> openSystemCamera({GalleryOptions? options}) async {
  if (!supportPlatformMobile) return null;
  options ??= GalleryOptions();
  String? path =
      await curiosityChannel.invokeMethod('openSystemCamera', options.toMap());
  if (isAndroid && options.savePath != null) path = options.savePath;
  return path;
}

/// 打开相薄 仅支持ios
Future<String?> openSystemAlbum({GalleryOptions? options}) async {
  if (!isIOS) return null;
  options ??= GalleryOptions();
  final String? path =
      await curiosityChannel.invokeMethod('openSystemAlbum', options.toMap());
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

/// 文件选择器macos
Future<List<String>> openFilePicker(
    {FilePickerOptionsWithMacOS? optionsWithMacOS}) async {
  if (!isMacOS) return <String>[];
  Map<String, dynamic> options = <String, dynamic>{};
  if (isMacOS) {
    optionsWithMacOS ??= FilePickerOptionsWithMacOS();
    options = optionsWithMacOS.toMap();
  }
  final List<dynamic>? path =
      await curiosityChannel.invokeMethod('openFilePicker', options);
  return path?.map((dynamic e) => e as String).toList() ?? <String>[];
}

/// 保存文件选择器macos
Future<String?> saveFilePicker(
    {SaveFilePickerOptionsWithMacOS? optionsWithMacOS}) async {
  if (!isMacOS) return null;
  Map<String, dynamic> options = <String, dynamic>{};
  if (isMacOS) {
    optionsWithMacOS ??= SaveFilePickerOptionsWithMacOS();
    options = optionsWithMacOS.toMap();
  }
  final String? path =
      await curiosityChannel.invokeMethod('saveFilePicker', options);
  return path;
}
