import 'package:flutter/services.dart';

const curiosity = 'Curiosity';
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
  ///android QUALITY_QVGA   ios 288
  Low,

  ///android 480P  ios 480
  Medium,

  ///android 720P  ios 720
  High,

  ///android 1080P  ios 1080
  VeryHigh,

  ///android 2160P  ios 2160
  UltraHigh,

  ///android QUALITY_HIGH  ios 最大
  Max
}
enum CameraLensFacing {
  /// 后置
  back,

  ///前置
  front,

  ///额外的
  external
}
