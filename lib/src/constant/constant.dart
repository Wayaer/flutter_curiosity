import 'package:flutter/services.dart';

const String curiosity = 'Curiosity';
const MethodChannel curiosityChannel = MethodChannel(curiosity);

enum ShareType {
  ///android ios
  text,

  ///android ios
  image,

  ///android ios
  images,

  ///ios
  url,
}
enum ResolutionPreset {
  ///android QUALITY_QVGA   ios 288*352
  Low,

  ///android 480*640  ios 480*640
  Medium,

  ///android 720*1280  ios 720*1280
  High,

  ///android 1080*1920  ios 1080*1920
  VeryHigh,

  ///android 2160*3840  ios 2160*3840
  UltraHigh,

  ///android QUALITY_HIGH  ios 最大
  Max
}
enum CameraLensFacing {
  ///后置
  back,

  ///前置
  front,

  ///其他的
  external
}

///Android 系统设置
enum SettingType {
  ///wifi
  wifi,

  ///定位
  location,

  ///安全中心
  security,

  ///蓝牙
  bluetooth,

  ///移动数据
  cellularNetwork,

  ///时间
  date,

  ///显示设置
  display,

  ///通知
  notification,

  ///声音设置
  sound,

  ///内部存储
  internalStorage,

  ///电量管理
  battery,

  ///nfc
  nfc,
}
