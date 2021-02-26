import 'package:flutter/services.dart';

const String curiosity = 'Curiosity';
const String _event = '$curiosity/event';
const String scannerEvent = '$_event/scanner';
const String connectivityEvent = '$_event/connectivity';

const MethodChannel curiosityChannel = MethodChannel(curiosity);

enum ShareType {
  /// android ios
  text,

  /// android ios
  image,

  /// android ios
  images,

  /// ios
  url,
}
enum CameraResolution {
  /// android QUALITY_QVGA   ios 288*352
  low,

  /// android 480*640  ios 480*640
  medium,

  /// android 720*1280  ios 720*1280
  high,

  /// android 1080*1920  ios 1080*1920
  veryHigh,

  /// android 2160*3840  ios 2160*3840
  ultraHigh,

  /// android QUALITY_HIGH  ios 最大
  Max
}
enum CameraLensFacing {
  /// 后置
  back,

  /// 前置
  front,

  /// 其他的
  external
}

/// Android 系统设置
enum SettingType {
  /// wifi
  wifi,

  /// 定位
  location,

  /// 密码安全
  passwordSecurity,

  /// 蓝牙
  bluetooth,

  /// 移动数据
  cellularNetwork,

  /// 语言和时间
  languageTime,

  /// 显示和亮度
  displayBrightness,

  /// 通知
  notification,

  /// 声音和振动
  soundVibration,

  /// 内部存储
  internalStorage,

  /// 电量管理
  battery,

  /// nfc
  nfc,

  /// setting
  setting
}

/// The status of the location service authorization.
enum LocationAuthorizeStatus {
  /// The authorization of the location service is not determined.
  notDetermined,

  /// This app is not authorized to use location.
  restricted,

  /// User explicitly denied the location service.
  denied,

  /// User authorized the app to access the location at any time.
  authorizedAlways,

  /// User authorized the app to access the location when the app is visible to them.
  authorizedWhenInUse,

  /// Status unknown.
  unknown
}

/// Connection status check result.
enum NetworkResult {
  /// WiFi: Device connected via Wi-Fi
  wifi,

  /// Mobile: Device connected to cellular network
  mobile,

  /// None: Device not connected to any network
  none
}
