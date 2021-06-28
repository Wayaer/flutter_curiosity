import 'package:flutter/services.dart';

const String curiosity = 'Curiosity';
const String curiosityEvent = 'curiosity/event';
const String scannerEvent = '$curiosity/event/scanner';

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

  /// wifi ip
  wifiIp,

  /// 定位
  location,

  /// 密码安全
  passwordSecurity,

  /// 蓝牙
  bluetooth,

  /// 移动数据
  cellularNetwork,

  /// 语言和时间
  time,

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

  /// 语言设置
  localeLanguage,

  /// nfc
  nfc,

  /// setting
  setting,

  /// 手机状态信息的界面
  deviceInfo,

  /// 开发者选项设置
  applicationDevelopment,

  /// 选取运营商的界面
  networkOperator,

  /// 添加账户界面
  addAccount,

  /// 双卡和移动网络设置界面
  dataRoaming,

  /// 更多连接方式设置界面
  airplaneMode
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
