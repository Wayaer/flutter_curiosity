import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/scanner/scanner.dart';
import 'package:flutter_curiosity/tools/internal.dart';

/// 识别图片 默认只识别 qrCode
Future<ScanResult?> scanImagePath(String path,
    {List<ScanType>? scanTypes}) async {
  scanTypes ??= <ScanType>[ScanType.qrCode];
  try {
    final File file = File(path);
    if (file.existsSync()) {
      return await scanImageByte(file.readAsBytesSync(), scanTypes: scanTypes);
    }
  } on PlatformException catch (e) {
    log(e);
  }
  return null;
}

/// 识别字节数组 默认只识别 qrCode
Future<ScanResult?> scanImageByte(Uint8List uint8list,
    {List<ScanType>? scanTypes}) async {
  try {
    scanTypes ??= <ScanType>[ScanType.qrCode];
    final Map<dynamic, dynamic>? data =
        await curiosityChannel.invokeMethod('scanImageByte', <String, dynamic>{
      'byte': uint8list,
      'useEvent': false,
      'scanTypes': scanTypes
          .map((ScanType e) => e.toString().split('.')[1])
          .toSet()
          .toList(),
    });
    if (data != null) return ScanResult.fromJson(data);
  } on PlatformException catch (e) {
    log(e);
  }
  return null;
}

/// 识别字节数组 默认只识别 qrCode
void scanImageYUV({
  required Uint8List uint8list,
  required int width,
  required int height,
  List<ScanType>? scanTypes,

  /// 识别区域设置
  /// [topRatio]  topRatio*height 为识别区域的top到图片最垂直向 0 的位置
  double topRatio = 0.3,

  /// [leftRatio]  leftRatio*width 为识别区域的left到图片最纵向 0 的位置
  double leftRatio = 0.1,

  /// [widthRatio]  widthRatio*width 为识别区域的宽
  double widthRatio = 0.8,

  /// [heightRatio]  heightRatio*height 为识别区域的高
  double heightRatio = 0.4,
}) {
  scanTypes ??= <ScanType>[ScanType.qrCode];
  if (isIOS) {
    curiosityChannel.invokeMethod<dynamic>('scanImageByte', <String, dynamic>{
      'byte': uint8list,
      'useEvent': true,
      'scanTypes': scanTypes
    });
  } else if (isAndroid) {
    try {
      final Map<String, dynamic> map = <String, dynamic>{
        'byte': uint8list,
        'width': width,
        'height': height,
        'topRatio': topRatio,
        'leftRatio': leftRatio,
        'widthRatio': widthRatio,
        'heightRatio': heightRatio,
        'scanTypes': scanTypes
            .map((ScanType e) => e.toString().split('.')[1])
            .toSet()
            .toList(),
      };
      curiosityChannel.invokeMethod<dynamic>('scanImageYUV', map);
    } on PlatformException catch (e) {
      log(e);
    }
  }
}
