import 'dart:convert' show json;

class AppInfoModel {
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
    cacheDir = json['cacheDir'] as String;
    versionName = json['versionName'].toString();
    directoryMusic = json['DIRECTORY_MUSIC'] as String;
    systemVersion = json['systemVersion'] as String;
    buildNumber = json['buildNumber'] as int;
    navigationBarHeight = json['navigationBarHeight'] as double;
    directoryAlarms = json['DIRECTORY_ALARMS'] as String;
    directoryDocuments = json['DIRECTORY_DOCUMENTS'] as String;
    firstInstallTime = json['firstInstallTime'] as int;
    phoneModel = json['phoneModel'] as String;
    phoneBrand = json['phoneBrand'] as String;
    packageName = json['packageName'] as String;
    directoryMovies = json['DIRECTORY_MOVIES'] as String;
    directoryPictures = json['DIRECTORY_PICTURES'] as String;
    filesDir = json['filesDir'] as String;
    directoryDCIM = json['DIRECTORY_DCIM'] as String;
    appName = json['appName'] as String;
    directoryNotifications = json['DIRECTORY_NOTIFICATIONS'] as String;
    directoryRINGTONES = json['DIRECTORY_RINGTONES'] as String;
    directoryDownloads = json['DIRECTORY_DOWNLOADS'] as String;
    versionCode = json['versionCode'] as int;
    externalCacheDir = json['externalCacheDir'] as String;
    externalFilesDir = json['externalFilesDir'] as String;
    directoryPODCASTS = json['DIRECTORY_PODCASTS'] as String;
    externalStorageDirectory = json['externalStorageDirectory'] as String;
    sdkVersion = json['sdkVersion'] as int;
    lastUpdateTime = json['lastUpdateTime'] as int;
    cachesDirectory = json['cachesDirectory'] as String;
    homeDirectory = json['homeDirectory'] as String;
    minimumOSVersion = json['minimumOSVersion'] as String;
    platformVersion = json['platformVersion'] as String;
    sdkBuild = json['sdkBuild'] as String;
    documentDirectory = json['documentDirectory'] as String;
    temporaryDirectory = json['temporaryDirectory'] as String;
    statusBarWidth = json['statusBarWidth'] as double;
    libraryDirectory = json['libraryDirectory'] as String;
    statusBarHeight = json['statusBarHeight'] as double;
    platformName = json['platformName'] as String;
    systemName = json['systemName'] as String;
  }

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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cacheDir'] = cacheDir;
    data['versionName'] = versionName;
    data['directory_music'] = directoryMusic;
    data['systemVersion'] = systemVersion;
    data['buildNumber'] = buildNumber;
    data['directory_alarms'] = directoryAlarms;
    data['directory_documents'] = directoryDocuments;
    data['firstInstallTime'] = firstInstallTime;
    data['phoneModel'] = phoneModel;
    data['phoneBrand'] = phoneBrand;
    data['packageName'] = packageName;
    data['directory_movies'] = directoryMovies;
    data['directory_pictures'] = directoryPictures;
    data['filesDir'] = filesDir;
    data['directory_dcim'] = directoryDCIM;
    data['appName'] = appName;
    data['directory_notifications'] = directoryNotifications;
    data['directory_ringtones'] = directoryRINGTONES;
    data['directory_downloads'] = directoryDownloads;
    data['versionCode'] = versionCode;
    data['externalCacheDir'] = externalCacheDir;
    data['externalFilesDir'] = externalFilesDir;
    data['directory_podcasts'] = directoryPODCASTS;
    data['externalStorageDirectory'] = externalStorageDirectory;
    data['sdkVersion'] = sdkVersion;
    data['lastUpdateTime'] = lastUpdateTime;
    data['cachesDirectory'] = cachesDirectory;
    data['homeDirectory'] = homeDirectory;
    data['minimumOSVersion'] = minimumOSVersion;
    data['platformVersion'] = platformVersion;
    data['sdkBuild'] = sdkBuild;
    data['documentDirectory'] = documentDirectory;
    data['temporaryDirectory'] = temporaryDirectory;
    data['statusBarWidth'] = statusBarWidth;
    data['libraryDirectory'] = libraryDirectory;
    data['statusBarHeight'] = statusBarHeight;
    data['platformName'] = platformName;
    data['systemName'] = systemName;
    data['navigationBarHeight'] = navigationBarHeight;
    return data;
  }
}

class AssetMedia {
  AssetMedia(
      {this.compressPath,
      this.duration,
      this.height,
      this.path,
      this.size,
      this.width,
      this.fileName,
      this.mediaType});

  AssetMedia.fromJson(Map<dynamic, dynamic> json) {
    compressPath = json['compressPath'] as String;
    duration = json['duration'] as int;
    path = json['path'] as String;
    size = intToDouble(json, 'size');
    height = intToDouble(json, 'height');
    width = intToDouble(json, 'width');
    fileName = json['fileName'] as String;
    mediaType = json['mediaType'] == null ? '' : json['mediaType'].toString();
  }

  double intToDouble(Map<dynamic, dynamic> json, String key) {
    final dynamic data = json[key];
    if (data is int) data.toDouble();
    if (data is double) return data;
    return null;
  }

  String compressPath;
  int duration;

  ///MediaTypeUnknown = 0, MediaTypeImage = 1,  MediaTypeVideo = 2, MediaTypeAudio = 3,
  ///only ios
  String mediaType;
  double height;
  String path;
  double size;
  double width;
  String fileName;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['compressPath'] = compressPath;
    data['duration'] = duration;
    data['height'] = height;
    data['height'] = height;
    data['path'] = path;
    data['size'] = size;
    data['width'] = width;
    data['fileName'] = fileName;
    data['mediaType'] = mediaType;
    return data;
  }

  @override
  String toString() => json.encode(this);
}

class PicturePickerOptions {
  PicturePickerOptions(
      {this.maxSelectNum = 6,
      this.minSelectNum = 1,
      this.imageSpanCount = 4,
      this.minimumCompressSize = 100,
      this.cropCompressQuality = 90,
      this.videoQuality = 0,
      this.videoMaxSecond = 60,
      this.videoMinSecond = 5,
      this.recordVideoSecond = 60,
      this.previewImage = false,
      this.previewVideo = false,
      this.isZoomAnim = true,
      this.isCamera = false,
      this.compress = false,
      this.freeStyleCropEnabled = false,
      this.openClickSound = false,
      this.isGif = false,
      this.setOutputCameraPath = '',
      this.originalPhoto = false,
      this.pickerSelectType = 0});

  ///支持ios && android
  ///
  /// 最大图片选择数量 int
  int maxSelectNum;

  ///是否显示原图按钮
  bool originalPhoto;

  /// 最小选择数量 int
  int minSelectNum;

  ///显示多少秒以内的视频or音频也可适用 int
  int videoMaxSecond;

  ///全部0、图片1、视频2
  int pickerSelectType;

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

  /// 裁剪框是否可拖拽 true or false
  bool freeStyleCropEnabled;

  /// 是否开启点击声音 true or false
  bool openClickSound;

  /// 自定义拍照保存路径,可不填
  String setOutputCameraPath;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['maxSelectNum'] = maxSelectNum ?? 6;
    data['minSelectNum'] = minSelectNum;
    data['imageSpanCount'] = imageSpanCount;
    data['minimumCompressSize'] = minimumCompressSize;
    data['cropCompressQuality'] = cropCompressQuality;
    data['videoQuality'] = videoQuality;
    data['videoMaxSecond'] = videoMaxSecond;
    data['videoMinSecond'] = videoMinSecond;
    data['recordVideoSecond'] = recordVideoSecond;
    data['previewImage'] = previewImage;
    data['previewVideo'] = previewVideo;
    data['isZoomAnim'] = isZoomAnim;
    data['compress'] = compress;
    data['isCamera'] = isCamera;
    data['freeStyleCropEnabled'] = freeStyleCropEnabled;
    data['openClickSound'] = openClickSound;
    data['isGif'] = isGif;
    data['pickerSelectType'] = pickerSelectType;
    data['setOutputCameraPath'] = setOutputCameraPath;
    data['originalPhoto'] = originalPhoto;
    return data;
  }
}
