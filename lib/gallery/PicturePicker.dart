import 'package:flutter_curiosity/constant/Constant.dart';
import 'package:flutter_curiosity/gallery/AssetMedia.dart';
import 'package:flutter_curiosity/gallery/PicturePickerOptions.dart';
import 'package:flutter_curiosity/tools/Tools.dart';

class PicturePicker {

  ///  openPicker() async {
  ///    PicturePickerOptions pickerOptions = PicturePickerOptions();
  ///    pickerOptions.selectValueType = 0;
  ///    pickerOptions.previewVideo = true;
  ///    var list = await PicturePicker.openPicker(pickerOptions);
  ///    print(list);
  ///  }
  static Future<List<AssetMedia>> openPicker(
      [PicturePickerOptions selectOptions]) async {
    Tools.supportPlatform();
    if (selectOptions == null) selectOptions = PicturePickerOptions();
    final result = await methodChannel.invokeMethod(
        'openPicker', selectOptions.toJson());
    if (result is List) {
      return Future.value(
          result.map((data) => AssetMedia.fromJson(data)).toList());
    } else {
      return Future.value([]);
    }
  }

  static Future<List<AssetMedia>> openCamera(
      [PicturePickerOptions selectOptions]) async {
    Tools.supportPlatform();
    if (selectOptions == null) selectOptions = PicturePickerOptions();
    final result =
    await methodChannel.invokeMethod('openCamera', selectOptions.toJson());
    if (result is List) {
      return Future.value(
          result.map((data) => AssetMedia.fromJson(data)).toList());
    } else {
      return Future.value([]);
    }
  }

  /// [selectValueType] 0:全部类型，1:图片，2:视频，3:音频
  static Future deleteCacheDirFile({int selectValueType = 0}) async {
    Tools.supportPlatform();
    return methodChannel.invokeMethod(
        'deleteCacheDirFile', {'selectValueType': selectValueType});
  }
}
