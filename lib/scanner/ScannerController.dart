import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_curiosity/constant/constant.dart';
import 'package:flutter_curiosity/constant/enum.dart';

class ScannerController extends ChangeNotifier {
  StreamSubscription eventChannel;
  String code;
  String type;
  int textureId;
  int previewWidth;
  int previewHeight;
  final String cameraId;
  final double topRatio;
  final double leftRatio;
  final double widthRatio;
  final double heightRatio;
  final ResolutionPreset resolutionPreset;

  ScannerController({
    ResolutionPreset resolutionPreset,
    this.topRatio: 0.3,
    this.cameraId: '0',
    this.leftRatio: 0.1,
    this.widthRatio: 0.8,
    this.heightRatio: 0.4,
  })  : this.resolutionPreset = resolutionPreset ?? ResolutionPreset.VeryHigh,
        assert(leftRatio * 2 + widthRatio == 1),
        assert(cameraId != null),
        assert(topRatio * 2 + heightRatio == 1);

  Future<void> initialize() async {
    try {
      final Map<String, dynamic> reply =
          await scannerChannel.invokeMapMethod('initialize', {
        'cameraId': cameraId,
        'resolutionPreset': resolutionPreset.toString().split('.')[1],
        "topRatio": topRatio,
        "leftRatio": leftRatio,
        "widthRatio": widthRatio,
        "heightRatio": heightRatio,
      });
      textureId = reply['textureId'];
      previewWidth = reply['previewWidth'];
      previewHeight = reply['previewHeight'];
      eventChannel = EventChannel('$scanner/$textureId/event')
          .receiveBroadcastStream({}).listen((data) {
        this.code = data['code'];
        this.type = data['type'];
        notifyListeners();
      });
    } on PlatformException catch (e) {
      //当发生权限问题的异常时会抛出
    }
  }

  Future<bool> setFlashMode(bool status) async {
    return await scannerChannel
        .invokeMethod('setFlashMode', {'status': status});
  }

  static Future<String> scanImagePath(String path) async {
    return await scannerChannel.invokeMethod('scanImagePath', {"path": path});
  }

  static Future<String> scanImageUrl(String url) async {
    return await scannerChannel.invokeMethod('scanImageUrl', {"url": url});
  }

  static Future<String> scanImageMemory(Uint8List uint8list) async {
    return await scannerChannel
        .invokeMethod('scanImageMemory', {"uint8list": uint8list});
  }

  Future<List<Cameras>> availableCameras() async {
    try {
      final List<Map<dynamic, dynamic>> cameras = await scannerChannel
          .invokeListMethod<Map<dynamic, dynamic>>('availableCameras');
      return cameras.map((camera) {
        return Cameras(name: camera['name'], lensFacing: camera['lensFacing']);
      }).toList();
    } on PlatformException catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    eventChannel?.cancel();
    notifyListeners();
    if (textureId == null) return;
    await scannerChannel.invokeMethod('dispose');
  }
}

class Cameras {
  final String name;
  final String lensFacing;

  Cameras({this.name, this.lensFacing});
}
