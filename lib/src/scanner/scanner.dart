import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/src/tools/internal.dart';

class Scanner extends StatefulWidget {
  final ScannerController controller;
  final CameraLensFacing cameraLensFacing;
  final Cameras camera;

  ///识别区域 比例 0-1
  ///距离屏幕头部
  final double topRatio;

  ///距离屏幕左边
  final double leftRatio;

  ///识别区域的宽高度比例
  final double widthRatio;

  ///识别区域的宽高度比例
  final double heightRatio;

  ///限制最佳宽高
  final bool bestFit;

  ///屏幕宽度比例=leftRatio + widthRatio + leftRatio
  ///屏幕高度比例=topRatio + heightRatio + topRatio

  Scanner({
    CameraLensFacing cameraLensFacing,
    this.controller,
    this.topRatio: 0.3,
    this.leftRatio: 0.1,
    this.widthRatio: 0.8,
    this.heightRatio: 0.4,
    this.camera,
    this.bestFit: true,
  })  : this.cameraLensFacing = cameraLensFacing ?? CameraLensFacing.back,
        assert(leftRatio * 2 + widthRatio == 1),
        assert(topRatio * 2 + heightRatio == 1),
        assert(controller != null);

  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> with WidgetsBindingObserver {
  ScannerController controller;
  Map<String, dynamic> params;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = widget.controller ?? ScannerController(resolutionPreset: ResolutionPreset.Max);
    getCameras();
  }

  getCameras() async {
    Cameras camera = widget.camera;
    if (camera == null) {
      var cameras = await controller.availableCameras();
      for (Cameras cameraInfo in cameras) {
        if (cameraInfo.lensFacing == widget.cameraLensFacing) {
          camera = cameraInfo;
          break;
        }
      }
    }
    if (camera == null) return;
    await controller.initialize(cameras: camera).then((value) {
      setState(() {});
    });
    print('cameraState ' + controller.cameraState);
  }

  @override
  Widget build(BuildContext context) {
    if (controller?.textureId == null) return Container();
    var texture = Texture(textureId: controller.textureId);
    if (widget.bestFit) {
      double h = 0;
      double w = InternalTools.getSize().width;
      double ratio = InternalTools.getDevicePixelRatio();
      if (controller.previewWidth != null && controller.previewHeight != null) {
        h = w * (controller.previewWidth / ratio) / (controller.previewHeight / ratio);
      }
      return Container(width: w, height: h, child: texture);
    }
    return texture;
  }

  @override
  void dispose() {
    controller.disposeCameras();
    controller.dispose();
    controller = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (controller != null) {
      if (state == AppLifecycleState.resumed) {
        getCameras();
      } else {
        controller.disposeCameras();
      }
    }
  }
}

class ScannerController extends ChangeNotifier {
  StreamSubscription eventChannel;
  String code;
  String type;
  int textureId;
  double previewWidth;
  double previewHeight;
  String cameraState;
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
  })  : this.resolutionPreset = resolutionPreset ?? ResolutionPreset.VeryHigh,
        assert(leftRatio * 2 + widthRatio == 1),
        assert(topRatio * 2 + heightRatio == 1);

  Future<void> initialize({Cameras cameras}) async {
    if (cameras == null && camera == null) return;
    try {
      final Map<String, dynamic> reply = await curiosityChannel.invokeMapMethod('initializeCameras', {
        'cameraId': cameras.name ?? camera.name,
        'resolutionPreset': resolutionPreset.toString().split('.')[1],
        "topRatio": topRatio,
        "leftRatio": leftRatio,
        "widthRatio": widthRatio,
        "heightRatio": heightRatio,
      });
      textureId = reply['textureId'];
      cameraState = reply['cameraState'] ?? '';
      previewWidth = double.parse(reply['previewWidth'].toString());
      previewHeight = double.parse(reply['previewHeight'].toString());
      eventChannel = EventChannel('$curiosity/event').receiveBroadcastStream({}).listen((data) {
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

  Future<String> setFlashMode(bool status) async =>
      await curiosityChannel.invokeMethod('setFlashMode', {'status': status});

  static Future<String> scanImagePath(String path) async =>
      await curiosityChannel.invokeMethod('scanImagePath', {"path": path});

  static Future<String> scanImageUrl(String url) async =>
      await curiosityChannel.invokeMethod('scanImageUrl', {"url": url});

  static Future<String> scanImageMemory(Uint8List uint8list) async =>
      await curiosityChannel.invokeMethod('scanImageMemory', {"uint8list": uint8list});

  Future<List<Cameras>> availableCameras() async {
    try {
      final List<Map<dynamic, dynamic>> cameras =
          await curiosityChannel.invokeListMethod<Map<dynamic, dynamic>>('availableCameras');
      return cameras.map((camera) {
        return Cameras(name: camera['name'], lensFacing: InternalTools.getCameraLensFacing(camera['lensFacing']));
      }).toList();
    } on PlatformException catch (e) {
      print(e);
      return null;
    }
  }

  Future disposeCameras() async {
    eventChannel?.cancel();
    await curiosityChannel.invokeMethod('disposeCameras', {'textureId': textureId});
  }
}

class Cameras {
  final String name;
  final CameraLensFacing lensFacing;

  Cameras({this.name, this.lensFacing});
}
