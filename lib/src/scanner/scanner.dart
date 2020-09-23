import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/src/constant/styles.dart';
import 'package:flutter_curiosity/src/tools/internal.dart';

///基于原始扫描预览
///使用简单
class ScannerPage extends StatefulWidget {
  const ScannerPage({
    Key key,
    CameraLensFacing cameraLensFacing,
    Color flashOnColor,
    Color flashOffColor,
    Color borderColor,
    Color scannerColor,
    this.topRatio = 0.3,
    this.leftRatio = 0.1,
    this.widthRatio = 0.8,
    this.heightRatio = 0.4,
    this.bestFit = true,
    this.hornStrokeWidth,
    this.scannerStrokeWidth,
    this.scannerBox = true,
    this.scanResult,
    this.child,
    this.flashText,
    this.resolutionPreset,
  })  : cameraLensFacing = cameraLensFacing ?? CameraLensFacing.back,
        borderColor = borderColor ?? Colors.white,
        scannerColor = scannerColor ?? Colors.white,
        flashOnColor = flashOnColor ?? Colors.white,
        flashOffColor = flashOffColor ?? Colors.black26,
        assert(leftRatio * 2 + widthRatio == 1),
        assert(topRatio * 2 + heightRatio == 1),
        assert(scannerBox != null),
        super(key: key);

  final CameraLensFacing cameraLensFacing;

  ///预览顶层添加组件
  final Widget child;

  ///扫描结果回调
  final ValueChanged<String> scanResult;

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
  final double hornStrokeWidth;
  final double scannerStrokeWidth;
  final Color borderColor;
  final Color scannerColor;
  final Color flashOnColor;
  final Color flashOffColor;
  final String flashText;

  //是否显示扫描框
  final bool scannerBox;
  final ResolutionPreset resolutionPreset;

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with WidgetsBindingObserver {
  ScannerController controller;
  double previewHeight = 0;
  double previewWidth = 0;
  bool isFirst = true;
  bool flash = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = ScannerController(resolutionPreset: widget.resolutionPreset ?? ResolutionPreset.High);
    WidgetsBinding.instance
        .addPostFrameCallback((Duration timeStamp) => Timer(const Duration(milliseconds: 300), () => initController()));
  }

  Future<void> initController() async {
    controller.addListener(() {
      final String code = controller.code;
      if (code != null && isFirst && code.isNotEmpty) {
        if (widget.scanResult != null) {
          isFirst = false;
          widget.scanResult(code);
        }
      }
    });
    controller.setFlashMode(false);
    getCameras();
  }

  Future<void> getCameras() async {
    Cameras camera;
    final List<Cameras> cameras = await controller.availableCameras();
    for (final Cameras cameraInfo in cameras) {
      if (cameraInfo.lensFacing == widget.cameraLensFacing) {
        camera = cameraInfo;
        break;
      }
    }
    if (camera == null) {
      return;
    }
    controller.initialize(cameras: camera).then((dynamic value) {
      final double ratio = InternalTools.getDevicePixelRatio();
      previewHeight = controller.previewHeight / ratio;
      previewWidth = controller.previewWidth / ratio;
      final double width = InternalTools.getSize().width;
      if (previewWidth > previewHeight) {
        previewHeight = previewWidth + previewHeight;
        previewWidth = previewHeight - previewWidth;
        previewHeight = previewHeight - previewWidth;
      }
      final double p = width / previewWidth;
      previewWidth = width;
      previewHeight = previewHeight * p;
      setState(() {});
      print('cameraState ' + controller.cameraState);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller?.textureId == null) {
      return Container();
    }
    Widget child = Scanner(controller: controller);
    final List<Widget> children = <Widget>[];
    children.add(Align(alignment: Alignment.center, child: child));
    if (widget.scannerBox) {
      children.add(ScannerBox(
        size: Size(previewWidth, previewHeight),
        borderColor: widget.borderColor,
        scannerColor: widget.scannerColor,
        hornStrokeWidth: widget.hornStrokeWidth,
        scannerStrokeWidth: widget.scannerStrokeWidth,
      ));
    }
    children.add(Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: GestureDetector(
            onTap: openFlash,
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Icon(Icons.highlight, size: 30, color: flash ? widget.flashOnColor : widget.flashOffColor),
              Text(widget.flashText ?? '轻触点亮',
                  style: Styles.textStyle(color: flash ? widget.flashOnColor : widget.flashOffColor))
            ])),
      ),
    ));
    if (widget.child != null) {
      children.add(widget.child);
    }
    child = Stack(children: children);
    if (widget.bestFit) {
      child = Container(width: previewWidth, height: previewHeight, child: child);
    }
    return child;
  }

  ///打开闪光灯
  Future<void> openFlash() async {
    if (controller == null) {
      controller.setFlashMode(!flash);
      flash = !flash;
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.disposeCameras();
    controller.dispose();
    controller = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller != null) {
      if (state == AppLifecycleState.resumed) {
        getCameras();
      } else {
        controller.disposeCameras();
      }
    }
  }
}

///原始扫描预览
///可以再此基础上定制其他样式预览
class Scanner extends StatelessWidget {
  const Scanner({Key key, this.controller}) : super(key: key);

  final ScannerController controller;

  @override
  Widget build(BuildContext context) {
    if (controller?.textureId == null) {
      return Container();
    }
    return Texture(textureId: controller.textureId);
  }
}

class ScannerController extends ChangeNotifier {
  ScannerController({
    ResolutionPreset resolutionPreset,
    this.topRatio = 0.3,
    this.camera,
    this.leftRatio = 0.1,
    this.widthRatio = 0.8,
    this.heightRatio = 0.4,
  })  : resolutionPreset = resolutionPreset ?? ResolutionPreset.VeryHigh,
        assert(leftRatio * 2 + widthRatio == 1),
        assert(topRatio * 2 + heightRatio == 1);

  final Cameras camera;
  final double topRatio;
  final double leftRatio;
  final double widthRatio;
  final double heightRatio;
  final ResolutionPreset resolutionPreset;

  StreamSubscription<dynamic> eventChannel;
  String code;
  String type;
  int textureId;
  double previewWidth;
  double previewHeight;
  String cameraState;

  Future<void> initialize({Cameras cameras}) async {
    if (cameras == null && camera == null) {
      return;
    }
    try {
      final Map<String, dynamic> arguments = <String, dynamic>{
        'cameraId': cameras.name ?? camera.name,
        'resolutionPreset': resolutionPreset.toString().split('.')[1],
        'topRatio': topRatio,
        'leftRatio': leftRatio,
        'widthRatio': widthRatio,
        'heightRatio': heightRatio,
      };

      final Map<String, dynamic> reply =
          await curiosityChannel.invokeMapMethod<String, dynamic>('initializeCameras', arguments);
      textureId = reply['textureId'] as int;
      cameraState = reply['cameraState'] as String ?? '';
      previewWidth = double.parse(reply['previewWidth'].toString());
      previewHeight = double.parse(reply['previewHeight'].toString());
      eventChannel = const EventChannel('$curiosity/event').receiveBroadcastStream().listen((dynamic data) {
        code = data['code'] as String;
        type = data['type'] as String;
        notifyListeners();
      });
    } on PlatformException catch (e) {
      //原生异常抛出
      print('initializeCameras PlatformException');
      print(e);
    }
  }

  Future<String> setFlashMode(bool status) async =>
      await curiosityChannel.invokeMethod('setFlashMode', <String, bool>{'status': status});

  static Future<String> scanImagePath(String path) async =>
      await curiosityChannel.invokeMethod('scanImagePath', <String, String>{'path': path});

  static Future<String> scanImageUrl(String url) async =>
      await curiosityChannel.invokeMethod('scanImageUrl', <String, String>{'url': url});

  static Future<String> scanImageMemory(Uint8List uint8list) async =>
      await curiosityChannel.invokeMethod('scanImageMemory', <String, Uint8List>{'uint8list': uint8list});

  Future<List<Cameras>> availableCameras() async {
    try {
      final List<Map<dynamic, dynamic>> cameras =
          await curiosityChannel.invokeListMethod<Map<dynamic, dynamic>>('availableCameras');
      return cameras.map((Map<dynamic, dynamic> camera) {
        return Cameras(
            name: camera['name'] as String,
            lensFacing: InternalTools.getCameraLensFacing(camera['lensFacing'] as String));
      }).toList();
    } on PlatformException catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> disposeCameras() async {
    eventChannel?.cancel();
    final Map<String, int> arguments = <String, int>{'textureId': textureId};
    return await curiosityChannel.invokeMethod('disposeCameras', arguments);
  }
}

class Cameras {
  Cameras({this.name, this.lensFacing});

  final String name;
  final CameraLensFacing lensFacing;
}
