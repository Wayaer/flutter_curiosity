import 'dart:convert' show json;

class AppInfoModel {
  String phoneBrand;
  String packageName;
  String versionName;
  int versionCode;
  String appName;
  String systemVersion;
  double statusBarHeight;

  ///only android
  String cacheDir;
  String directoryMusic;
  String directoryAlarms;
  String directoryDocuments;
  int firstInstallTime;
  String phoneModel;
  String directoryMovies;
  String directoryPictures;
  String filesDir;
  String directoryDCIM;
  String directoryNotifications;
  String directoryRINGTONES;
  String directoryDownloads;
  String externalCacheDir;
  String externalFilesDir;
  String directoryPODCASTS;
  String externalStorageDirectory;
  int sdkVersion;
  int lastUpdateTime;
  int buildNumber;
  double navigationBarHeight;

  ///only ios
  String cachesDirectory;
  String homeDirectory;
  String minimumOSVersion;
  String platformVersion;
  String sdkBuild;
  String documentDirectory;
  String temporaryDirectory;
  double statusBarWidth;
  String libraryDirectory;
  String platformName;
  String systemName;

  AppInfoModel(
      {this.cacheDir,
      this.versionName,
      this.directoryMusic,
      this.systemVersion,
      this.buildNumber,
      this.directoryAlarms,
      this.directoryDocuments,
      this.firstInstallTime,
      this.phoneModel,
      this.phoneBrand,
      this.packageName,
      this.directoryMovies,
      this.directoryPictures,
      this.filesDir,
      this.directoryDCIM,
      this.appName,
      this.navigationBarHeight,
      this.directoryNotifications,
      this.directoryRINGTONES,
      this.directoryDownloads,
      this.versionCode,
      this.externalCacheDir,
      this.externalFilesDir,
      this.directoryPODCASTS,
      this.externalStorageDirectory,
      this.sdkVersion,
      this.cachesDirectory,
      this.homeDirectory,
      this.minimumOSVersion,
      this.platformVersion,
      this.sdkBuild,
      this.documentDirectory,
      this.temporaryDirectory,
      this.statusBarWidth,
      this.libraryDirectory,
      this.statusBarHeight,
      this.platformName,
      this.systemName,
      this.lastUpdateTime});

  AppInfoModel.fromJson(Map<String, dynamic> json) {
    cacheDir = json['cacheDir'];
    versionName = json['versionName'].toString();
    directoryMusic = json['DIRECTORY_MUSIC'];
    systemVersion = json['systemVersion'];
    buildNumber = json['buildNumber'];
    navigationBarHeight = json['navigationBarHeight'];
    directoryAlarms = json['DIRECTORY_ALARMS'];
    directoryDocuments = json['DIRECTORY_DOCUMENTS'];
    firstInstallTime = json['firstInstallTime'];
    phoneModel = json['phoneModel'];
    phoneBrand = json['phoneBrand'];
    packageName = json['packageName'];
    directoryMovies = json['DIRECTORY_MOVIES'];
    directoryPictures = json['DIRECTORY_PICTURES'];
    filesDir = json['filesDir'];
    directoryDCIM = json['DIRECTORY_DCIM'];
    appName = json['appName'];
    directoryNotifications = json['DIRECTORY_NOTIFICATIONS'];
    directoryRINGTONES = json['DIRECTORY_RINGTONES'];
    directoryDownloads = json['DIRECTORY_DOWNLOADS'];
    versionCode = json['versionCode'];
    externalCacheDir = json['externalCacheDir'];
    externalFilesDir = json['externalFilesDir'];
    directoryPODCASTS = json['DIRECTORY_PODCASTS'];
    externalStorageDirectory = json['externalStorageDirectory'];
    sdkVersion = json['sdkVersion'];
    lastUpdateTime = json['lastUpdateTime'];
    cachesDirectory = json['cachesDirectory'];
    homeDirectory = json['homeDirectory'];
    minimumOSVersion = json['minimumOSVersion'];
    platformVersion = json['platformVersion'];
    sdkBuild = json['sdkBuild'];
    documentDirectory = json['documentDirectory'];
    temporaryDirectory = json['temporaryDirectory'];
    statusBarWidth = json['statusBarWidth'];
    libraryDirectory = json['libraryDirectory'];
    statusBarHeight = json['statusBarHeight'];
    platformName = json['platformName'];
    systemName = json['systemName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cacheDir'] = this.cacheDir;
    data['versionName'] = this.versionName;
    data['directory_music'] = this.directoryMusic;
    data['systemVersion'] = this.systemVersion;
    data['buildNumber'] = this.buildNumber;
    data['directory_alarms'] = this.directoryAlarms;
    data['directory_documents'] = this.directoryDocuments;
    data['firstInstallTime'] = this.firstInstallTime;
    data['phoneModel'] = this.phoneModel;
    data['phoneBrand'] = this.phoneBrand;
    data['packageName'] = this.packageName;
    data['directory_movies'] = this.directoryMovies;
    data['directory_pictures'] = this.directoryPictures;
    data['filesDir'] = this.filesDir;
    data['directory_dcim'] = this.directoryDCIM;
    data['appName'] = this.appName;
    data['directory_notifications'] = this.directoryNotifications;
    data['directory_ringtones'] = this.directoryRINGTONES;
    data['directory_downloads'] = this.directoryDownloads;
    data['versionCode'] = this.versionCode;
    data['externalCacheDir'] = this.externalCacheDir;
    data['externalFilesDir'] = this.externalFilesDir;
    data['directory_podcasts'] = this.directoryPODCASTS;
    data['externalStorageDirectory'] = this.externalStorageDirectory;
    data['sdkVersion'] = this.sdkVersion;
    data['lastUpdateTime'] = this.lastUpdateTime;
    data['cachesDirectory'] = this.cachesDirectory;
    data['homeDirectory'] = this.homeDirectory;
    data['minimumOSVersion'] = this.minimumOSVersion;
    data['platformVersion'] = this.platformVersion;
    data['sdkBuild'] = this.sdkBuild;
    data['documentDirectory'] = this.documentDirectory;
    data['temporaryDirectory'] = this.temporaryDirectory;
    data['statusBarWidth'] = this.statusBarWidth;
    data['libraryDirectory'] = this.libraryDirectory;
    data['statusBarHeight'] = this.statusBarHeight;
    data['platformName'] = this.platformName;
    data['systemName'] = this.systemName;
    data['navigationBarHeight'] = this.navigationBarHeight;
    return data;
  }
}

dynamic convertValueByType(value, Type type, {String stack: ""}) {
  if (value == null) {
    ///    log("$stack : value is null");
    if (type == String) {
      return "";
    } else if (type == int) {
      return 0;
    } else if (type == double) {
      return 0.0;
    } else if (type == bool) {
      return false;
    }
    return null;
  }

  if (value.runtimeType == type) return value;

  var valueString = value.toString();

  ///  log("$stack : ${value.runtimeType} is not $type type");
  if (type == String) {
    return valueString;
  } else if (type == int) {
    return int.tryParse(valueString);
  } else if (type == double) {
    return double.tryParse(valueString);
  } else if (type == bool) {
    valueString = valueString.toLowerCase();
    var intValue = int.tryParse(valueString);
    if (intValue != null) {
      return intValue == 1;
    }
    return valueString == "true";
  }
}

class AssetMedia {
  String compressPath;
  String cropPath;
  int duration;
  String mediaType;
  int height;
  String path;
  int size;
  int width;
  String fileName;

  AssetMedia(
      {this.compressPath,
      this.cropPath,
      this.duration,
      this.height,
      this.path,
      this.size,
      this.width,
      this.fileName,
      this.mediaType});

  factory AssetMedia.fromJson(jsonRes) => jsonRes == null
      ? null
      : AssetMedia(
          compressPath: convertValueByType(jsonRes['compressPath'], String, stack: "AssetMedia-compressPath"),
          mediaType: convertValueByType(jsonRes['mediaType'], String, stack: "AssetMedia-mediaType"),
          fileName: convertValueByType(jsonRes['fileName'], String, stack: "AssetMedia-fileName"),
          cropPath: convertValueByType(jsonRes['cutPath'], String, stack: "AssetMedia-cutPath"),
          duration: convertValueByType(jsonRes['duration'], int, stack: "AssetMedia-duration"),
          height: convertValueByType(jsonRes['height'], int, stack: "AssetMedia-height"),
          path: convertValueByType(jsonRes['path'], String, stack: "AssetMedia-path"),
          size: convertValueByType(jsonRes['size'], int, stack: "AssetMedia-size"),
          width: convertValueByType(jsonRes['width'], int, stack: "AssetMedia-width"),
        );

  Map<String, dynamic> toJson() => {
        'compressPath': compressPath,
        'cutPath': cropPath,
        'duration': duration,
        'height': height,
        'path': path,
        'size': size,
        'width': width,
        'fileName': fileName,
        'mediaType': mediaType,
      };

  @override
  String toString() => json.encode(this);
}

class PicturePickerOptions {
  ///支持ios && android
  ///
  /// 最大图片选择数量 int
  int maxSelectNum;

  ///是否显示原图按钮
  bool originalPhoto;

  /// 最小选择数量 int
  int minSelectNum;

  ///裁剪比例 如16:9 3:2 3:4 1:1 可自定义  宽
  int cropW;

  ///裁剪比例 如16:9 3:2 3:4 1:1 可自定义  高
  int cropH;

  ///显示多少秒以内的视频or音频也可适用 int
  int videoMaxSecond;

//  ///全部0、图片1、视频2
  int pickerSelectType;

  /// 是否裁剪 true or false
  bool enableCrop;

  /// 是否可预览图片 true or false
  bool previewImage;

  /// 是否显示拍照按钮 true or false
  bool isCamera;

  /// 是否显示gif图片 true or false
  bool isGif;

  ///android 以下为仅支持 android
  ///
  /// 每行显示个数 int
  int imageSpanCount;

  /// 裁剪压缩质量 默认90 int
  int cropCompressQuality;

  /// 小于100kb的图片不压缩
  int minimumCompressSize;

  ///视频录制质量 0 or 1 int
  int videoQuality;

  /// 显示多少秒以内的视频or音频也可适用 int
  int videoMinSecond;

  ///视频秒数录制 默认60s int
  int recordVideoSecond;

  /// 是否可预览视频 true or false
  bool previewVideo;

  /// 图片列表点击 缩放效果 默认true
  bool isZoomAnim;

  /// 是否压缩 true or false
  bool compress;

  /// 是否显示uCrop工具栏，默认不显示 true or false
  bool hideBottomControls;

  /// 裁剪框是否可拖拽 true or false
  bool freeStyleCropEnabled;

  /// 是否圆形裁剪 true or false
  bool showCropCircle;

  /// 是否显示矩形 圆形裁剪时建议设为false    true or false
  bool showCropFrame;

  /// 是否显示网格 圆形裁剪时建议设为false    true or false
  bool showCropGrid;

  /// 是否开启点击声音 true or false
  bool openClickSound;

  /// 裁剪是否可旋转图片 true or false
  bool rotateEnabled;

  /// 裁剪是否可放大缩小图片 true or false
  bool scaleEnabled;

  /// 自定义拍照保存路径,可不填
  String setOutputCameraPath;

  ///ios 以下为仅支持 ios
  ///
  ///圆形裁剪框半径大小  在单选模式下，照片列表页中，显示选择按钮,默认为false
  int circleCropRadius;

  ///是否图片等比缩放填充cropRect区域   在单选模式下，照片列表页中，显示选择按钮,默认为false
  bool scaleAspectFillCrop;

  PicturePickerOptions(
      {this.maxSelectNum: 6,
      this.minSelectNum: 1,
      this.imageSpanCount: 4,
      this.minimumCompressSize: 100,
      this.cropW: 4,
      this.cropH: 3,
      this.cropCompressQuality: 90,
      this.videoQuality: 0,
      this.videoMaxSecond: 60,
      this.videoMinSecond: 5,
      this.recordVideoSecond: 60,
      this.previewImage: false,
      this.previewVideo: false,
      this.isZoomAnim: true,
      this.isCamera: false,
      this.enableCrop: false,
      this.compress: false,
      this.hideBottomControls: false,
      this.freeStyleCropEnabled: false,
      this.showCropCircle: false,
      this.showCropFrame: false,
      this.showCropGrid: false,
      this.openClickSound: false,
      this.isGif: false,
      this.scaleAspectFillCrop: false,
      this.setOutputCameraPath: "",
      this.rotateEnabled: false,
      this.originalPhoto: false,
      this.scaleEnabled: false,
      this.pickerSelectType: 0});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['maxSelectNum'] = this.maxSelectNum ?? 6;
    data['minSelectNum'] = this.minSelectNum;
    data['imageSpanCount'] = this.imageSpanCount;
    data['minimumCompressSize'] = this.minimumCompressSize;
    data['cropW'] = this.cropW;
    data['cropH'] = this.cropH;
    data['cropCompressQuality'] = this.cropCompressQuality;
    data['videoQuality'] = this.videoQuality;
    data['videoMaxSecond'] = this.videoMaxSecond;
    data['videoMinSecond'] = this.videoMinSecond;
    data['recordVideoSecond'] = this.recordVideoSecond;
    data['previewImage'] = this.previewImage;
    data['previewVideo'] = this.previewVideo;
    data['isZoomAnim'] = this.isZoomAnim;
    data['enableCrop'] = this.enableCrop;
    data['compress'] = this.compress;
    data['isCamera'] = this.isCamera;
    data['hideBottomControls'] = this.hideBottomControls;
    data['freeStyleCropEnabled'] = this.freeStyleCropEnabled;
    data['showCropCircle'] = this.showCropCircle;
    data['showCropFrame'] = this.showCropFrame;
    data['showCropGrid'] = this.showCropGrid;
    data['openClickSound'] = this.openClickSound;
    data['isGif'] = this.isGif;
    data['rotateEnabled'] = this.rotateEnabled;
    data['scaleEnabled'] = this.scaleEnabled;
    data['pickerSelectType'] = this.pickerSelectType;
    data['setOutputCameraPath'] = this.setOutputCameraPath;
    data['scaleAspectFillCrop'] = this.scaleAspectFillCrop;
    data['originalPhoto'] = this.originalPhoto;
    return data;
  }
}
