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
enum ResolutionPreset { Low, Medium, High, VeryHigh, UltraHigh, Max }
enum CameraLensFacing {
  /// 后置
  back,

  ///前置
  front,

  ///额外的
  external
}
