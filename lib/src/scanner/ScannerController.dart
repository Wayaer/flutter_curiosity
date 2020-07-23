import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/src/tools/InternalTools.dart';

class ScannerController extends ChangeNotifier {
  StreamSubscription eventChannel;
  String code;
  String type;
  int textureId;
  double previewWidth;
  double previewHeight;
  final Cameras camera;
  final double topRatio;
  final double leftRatio;
  final double widthRatio;
  final double heightRatio;
  final ResolutionPreset resolutionPreset;

  ScannerController({
    ResolutionPreset resolutionPreset,
    this.topRatio: 0.3,
    this.camera,
    this.leftRatio: 0.1,
    this.widthRatio: 0.8,
    this.heightRatio: 0.4,
  })  : this.resolutionPreset = resolutionPreset ?? ResolutionPreset.Max,
        assert(leftRatio * 2 + widthRatio == 1),
        assert(topRatio * 2 + heightRatio == 1);

  Future<void> initialize({Cameras cameras}) async {
    if (cameras == null && camera == null) return;
    try {
      final Map<String, dynamic> reply =
          await curiosityChannel.invokeMapMethod('initializeCameras', {
        'cameraId': cameras.name ?? camera.name,
        'resolutionPreset': resolutionPreset.toString().split('.')[1],
        "topRatio": topRatio,
        "leftRatio": leftRatio,
        "widthRatio": widthRatio,
        "heightRatio": heightRatio,
      });
      textureId = reply['textureId'];
      previewWidth = double.parse(reply['previewWidth'].toString());
      previewHeight = double.parse(reply['previewHeight'].toString());
      eventChannel = EventChannel('$curiosity/event')
          .receiveBroadcastStream({}).listen((data) {
        this.code = data['code'];
        this.type = data['type'];
        notifyListeners();
      });
    } on PlatformException catch (e) {
      //原生异常抛出
      print("initializeCameras PlatformException");
      print(e);
    }
  }

  Future<String> setFlashMode(bool status) async {
    return await curiosityChannel
        .invokeMethod('setFlashMode', {'status': status});
  }

  static Future<String> scanImagePath(String path) async {
    return await curiosityChannel.invokeMethod('scanImagePath', {"path": path});
  }

  static Future<String> scanImageUrl(String url) async {
    return await curiosityChannel.invokeMethod('scanImageUrl', {"url": url});
  }

  static Future<String> scanImageMemory(Uint8List uint8list) async {
    return await curiosityChannel
        .invokeMethod('scanImageMemory', {"uint8list": uint8list});
  }

  Future<List<Cameras>> availableCameras() async {
    try {
      final List<Map<dynamic, dynamic>> cameras = await curiosityChannel
          .invokeListMethod<Map<dynamic, dynamic>>('availableCameras');
      return cameras.map((camera) {
        return Cameras(
            name: camera['name'],
            lensFacing:
                InternalTools.getCameraLensFacing(camera['lensFacing']));
      }).toList();
    } on PlatformException catch (e) {
      print(e);
      return null;
    }
  }

  Future disposeCameras() async {
    eventChannel?.cancel();
    await curiosityChannel
        .invokeMethod('disposeCameras', {'textureId': textureId});
  }
}

class Cameras {
  final String name;
  final CameraLensFacing lensFacing;

  Cameras({this.name, this.lensFacing});
}
