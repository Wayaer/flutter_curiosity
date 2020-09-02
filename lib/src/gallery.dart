import 'dart:typed_data';

import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/src/tools/internal.dart';

class GalleryTools {
  ///  openPicker() async {
  ///    PicturePickerOptions pickerOptions = PicturePickerOptions();
  ///    pickerOptions.selectValueType = 0;
  ///    pickerOptions.previewVideo = true;
  ///    var list = await PicturePicker.openPicker(pickerOptions);
  ///    print(list);
  ///  }
  static Future<List<AssetMedia>> openImagePicker(
      [PicturePickerOptions selectOptions]) async {
       if (InternalTools.supportPlatform()) return null;
    if (selectOptions == null) selectOptions = PicturePickerOptions();
    if (selectOptions.maxSelectNum < 1) selectOptions.maxSelectNum = 1;
    final result = await curiosityChannel.invokeMethod(
        'openImagePicker', selectOptions.toJson());
    if (result is List) {
      print(result.length);
      return Future.value(
          result.map((data) => AssetMedia.fromJson(data)).toList());
    } else {
      return Future.value([]);
    }
  }

  /// [selectValueType] 0:全部类型，1:图片，2:视频
  static Future deleteCacheDirFile({int selectValueType = 0}) async {
       if (InternalTools.supportPlatform()) return null;
    return curiosityChannel.invokeMethod(
        'deleteCacheDirFile', {'selectValueType': selectValueType});
  }

  ///打开系统相册
  ///返回文件路径
  ///ios info.plist add
  ///       <key>NSPhotoLibraryUsageDescription</key>
  ///       <string>是否允许Curiosity访问你的相册？</string>
  ///ios path 包含 file:///
  static Future<String> openSystemGallery() async {
       if (InternalTools.supportPlatform()) return null;
    return await curiosityChannel.invokeMethod('openSystemGallery');
  }

  ///打开系统相机
  ///返回文件路径
  ///Android AndroidManifest.xml 添加以下内容
  ///<application
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
  ///</application>
  ///ios info.plist add
  ///     <key>NSCameraUsageDescription</key>
  ///       <string>是否允许APP使用你的相机？</string>
  ///      <key>NSPhotoLibraryUsageDescription</key>
  ///       <string>是否允许APP访问你的相册？</string>
  ///ios path 包含 file:///
  static Future<String> openSystemCamera({String savePath}) async {
    ///savePath => android 图片临时储存位置 (仅支持android)
    ///alertNativeTips => ios 是否弹出用户未允许访问相机权限提示 (仅支持ios)
       if (InternalTools.supportPlatform()) return null;
    var path = await curiosityChannel
        .invokeMethod('openSystemCamera', {"path": savePath});
    if (savePath != null) path = savePath;
    return path;
  }

  /// save image to Gallery
  /// imageBytes can't null
  static Future<String> saveImageToGallery(Uint8List imageBytes,
      {int quality = 100, String name}) async {
    assert(imageBytes != null);
    final result = await curiosityChannel.invokeMethod(
        'saveImageToGallery', <String, dynamic>{
      'imageBytes': imageBytes,
      'quality': quality,
      'name': name
    });
    return result;
  }

  /// Save the PNG，JPG，JPEG image or video located at [file] to the local device media gallery.
  static Future<String> saveFileToGallery(String file) async {
    assert(file != null);
    final result =
        await curiosityChannel.invokeMethod('saveFileToGallery', file);
    return result;
  }
}
