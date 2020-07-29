import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/src/tools/InternalTools.dart';

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
  })
      : this.cameraLensFacing = cameraLensFacing ?? CameraLensFacing.back,
        assert(leftRatio * 2 + widthRatio == 1),
        assert(topRatio * 2 + heightRatio == 1),
        assert(controller != null);

  @override
  State<StatefulWidget> createState() => ScannerState();
}

class ScannerState extends State<Scanner> with WidgetsBindingObserver {
  ScannerController controller;
  Map<String, dynamic> params;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = widget.controller ??
        ScannerController(resolutionPreset: ResolutionPreset.Max);
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
    return Texture(textureId: controller.textureId);
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
