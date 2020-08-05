import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/src/tools/InternalTools.dart';

class PicturePicker {
  ///  openPicker() async {
  ///    PicturePickerOptions pickerOptions = PicturePickerOptions();
  ///    pickerOptions.selectValueType = 0;
  ///    pickerOptions.previewVideo = true;
  ///    var list = await PicturePicker.openPicker(pickerOptions);
  ///    print(list);
  ///  }
  static Future<List<AssetMedia>> openImagePicker(
      [PicturePickerOptions selectOptions]) async {
    InternalTools.supportPlatform();
    if (selectOptions == null) selectOptions = PicturePickerOptions();
    if (selectOptions.maxSelectNum < 1) selectOptions.maxSelectNum = 1;
    final result = await curiosityChannel.invokeMethod(
        'openImagePicker', selectOptions.toJson());
//    print(result);
    if (result is List) {
      print(result.length);
      return Future.value(
          result.map((data) => AssetMedia.fromJson(data)).toList());
    } else {
      return Future.value([]);
    }
  }

  static Future<dynamic> openCamera(
      [PicturePickerOptions selectOptions]) async {
    InternalTools.supportPlatform();
    if (selectOptions == null) selectOptions = PicturePickerOptions();
    if (selectOptions.maxSelectNum < 1) selectOptions.maxSelectNum = 1;
    final result = await curiosityChannel.invokeMethod(
        'openCamera', selectOptions.toJson());
    if (InternalTools.isIOS()) return result;
    if (result is List) {
      return Future.value(
          result.map((data) => AssetMedia.fromJson(data)).toList());
    } else {
      return Future.value([]);
    }
  }

  /// [selectValueType] 0:全部类型，1:图片，2:视频
  static Future deleteCacheDirFile({int selectValueType = 0}) async {
    InternalTools.supportPlatform();
    return curiosityChannel.invokeMethod(
        'deleteCacheDirFile', {'selectValueType': selectValueType});
  }
}
