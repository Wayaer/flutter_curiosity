import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_curiosity/constant/styles.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/tools/internal.dart';

/// 基于原始扫描预览
/// 使用简单
class ScannerView extends StatefulWidget {
  const ScannerView({
    Key? key,
    CameraLensFacing? lensFacing,
    Color? flashOnColor,
    Color? flashOffColor,
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
    this.resolution,
    this.borderColor,
    this.scannerColor,
  })  : lensFacing = lensFacing ?? CameraLensFacing.back,
        flashOnColor = flashOnColor ?? Colors.white,
        flashOffColor = flashOffColor ?? Colors.black26,
        assert(leftRatio * 2 + widthRatio == 1),
        assert(topRatio * 2 + heightRatio == 1),
        super(key: key);

  /// 相机位置
  final CameraLensFacing lensFacing;

  /// 预览顶层添加组件
  final Widget? child;

  /// 扫描结果回调
  final ValueChanged<String>? scanResult;

  /// 识别区域 比例 0-1
  /// 距离屏幕头部
  final double topRatio;

  /// 距离屏幕左边
  final double leftRatio;

  /// 识别区域的宽高度比例
  final double widthRatio;

  /// 识别区域的宽高度比例
  final double heightRatio;

  /// 限制最佳宽高
  final bool bestFit;

  /// 屏幕宽度比例=leftRatio + widthRatio + leftRatio
  /// 屏幕高度比例=topRatio + heightRatio + topRatio
  /// 中间线条宽度
  final double? hornStrokeWidth;

  /// 边框宽度
  final double? scannerStrokeWidth;
  final Color? borderColor;
  final Color? scannerColor;
  final Color flashOnColor;
  final Color flashOffColor;
  final String? flashText;

  /// 是否显示扫描框
  final bool scannerBox;
  final CameraResolution? resolution;

  @override
  _ScannerViewState createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> with WidgetsBindingObserver {
  ScannerController? controller;
  double previewHeight = 0;
  double previewWidth = 0;
  bool isFirst = true;
  bool flash = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    controller = ScannerController(
        resolution: widget.resolution ?? CameraResolution.high);
    WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) =>
        Timer(const Duration(milliseconds: 300), () => initController()));
  }

  Future<void> initController() async {
    controller!.addListener(() {
      final String? code = controller?.scanResult?.code;
      if (code != null && isFirst && code.isNotEmpty) {
        if (widget.scanResult != null) {
          isFirst = false;
          widget.scanResult!(code);
        }
      }
    });
    controller!.setFlashMode(false);
    getCameras();
  }

  Future<void> getCameras() async {
    Cameras? camera;
    final List<Cameras>? cameras = await controller!.availableCameras();
    if (cameras == null) return;
    for (final Cameras cameraInfo in cameras) {
      if (cameraInfo.lensFacing == widget.lensFacing) {
        camera = cameraInfo;
        break;
      }
    }
    if (camera == null) return;
    controller!.initialize(cameras: camera).then((dynamic value) {
      final double ratio = getDevicePixelRatio;
      if (controller!.previewHeight == null || controller!.previewWidth == null)
        return;
      previewHeight = controller!.previewHeight! / ratio;
      previewWidth = controller!.previewWidth! / ratio;
      final double width = getWindowSize.width;
      if (previewWidth > previewHeight) {
        previewHeight = previewWidth + previewHeight;
        previewWidth = previewHeight - previewWidth;
        previewHeight = previewHeight - previewWidth;
      }
      final double p = width / previewWidth;
      previewWidth = width;
      previewHeight = previewHeight * p;
      setState(() {});
      if (controller!.cameraState == null) return;
      log('cameraState ' + controller!.cameraState!);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller?.textureId == null) return Container();
    Widget child = Scanner(controller: controller!);
    final List<Widget> children = <Widget>[];
    children.add(Align(alignment: Alignment.center, child: child));
    if (widget.scannerBox) {
      children.add(ScannerBox(
          size: Size(previewWidth, previewHeight),
          borderColor: widget.borderColor,
          scannerColor: widget.scannerColor,
          hornStrokeWidth: widget.hornStrokeWidth,
          scannerStrokeWidth: widget.scannerStrokeWidth));
    }
    children.add(Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: GestureDetector(
            onTap: openFlash,
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Icon(Icons.highlight,
                  size: 30,
                  color: flash ? widget.flashOnColor : widget.flashOffColor),
              Text(widget.flashText ?? '轻触点亮',
                  style: BaseTextStyle(
                      color:
                          flash ? widget.flashOnColor : widget.flashOffColor))
            ])),
      ),
    ));
    if (widget.child != null) children.add(widget.child!);
    child = Stack(children: children);
    if (widget.bestFit)
      child =
          Container(width: previewWidth, height: previewHeight, child: child);
    return child;
  }

  /// 打开闪光灯
  Future<void> openFlash() async {
    if (controller != null) {
      controller!.setFlashMode(!flash);
      flash = !flash;
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller!.disposeCameras();
    controller!.dispose();
    controller = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller != null) {
      if (state == AppLifecycleState.resumed) {
        getCameras();
      } else {
        controller!.disposeCameras();
      }
    }
  }
}

/// 原始扫描预览
/// 可以再此基础上定制其他样式预览
class Scanner extends StatelessWidget {
  const Scanner({Key? key, required this.controller}) : super(key: key);

  final ScannerController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.textureId == null) return Container();
    return Texture(textureId: controller.textureId!);
  }
}

class ScannerController extends ChangeNotifier {
  ScannerController({
    CameraResolution? resolution,
    this.topRatio = 0.3,
    this.camera,
    this.leftRatio = 0.1,
    this.widthRatio = 0.8,
    this.heightRatio = 0.4,
  })  : resolution = resolution ?? CameraResolution.veryHigh,
        assert(leftRatio * 2 + widthRatio == 1),
        assert(topRatio * 2 + heightRatio == 1);

  final Cameras? camera;
  final double topRatio;
  final double leftRatio;
  final double widthRatio;
  final double heightRatio;
  final CameraResolution resolution;

  StreamSubscription<dynamic>? _streamSubscription;
  ScanResult? scanResult;
  int? textureId;
  double? previewWidth;
  double? previewHeight;
  String? cameraState;
  EventChannel? _eventChannel;

  Future<void> initialize({Cameras? cameras}) async {
    if (cameras == null && camera == null) return;
    try {
      final Map<String, dynamic> arguments = <String, dynamic>{
        'cameraId': cameras?.name ?? camera!.name,
        'resolutionPreset': resolution.toString().split('.')[1],
        'topRatio': topRatio,
        'leftRatio': leftRatio,
        'widthRatio': widthRatio,
        'heightRatio': heightRatio,
      };
      final Map<String, dynamic>? reply = await curiosityChannel
          .invokeMapMethod<String, dynamic>('initializeCameras', arguments);
      if (reply == null) return;
      textureId = reply['textureId'] as int;
      cameraState = reply['cameraState'] as String;
      previewWidth = double.parse(reply['previewWidth'].toString());
      previewHeight = double.parse(reply['previewHeight'].toString());
      _eventChannel = const EventChannel(scannerEvent);
      _streamSubscription = _eventChannel!
          .receiveBroadcastStream(<dynamic, dynamic>{}).listen((dynamic data) {
        scanResult = ScanResult.fromJson(data as Map<dynamic, dynamic>);
        notifyListeners();
      });
    } on PlatformException catch (e) {
      /// 原生异常抛出
      log('initializeCameras PlatformException');
      log(e);
    }
  }

  Future<String?> setFlashMode(bool status) async => await curiosityChannel
      .invokeMethod('setFlashMode', <String, bool>{'status': status});

  Future<List<Cameras>?> availableCameras() async {
    try {
      final List<Map<dynamic, dynamic>>? cameras = await curiosityChannel
          .invokeListMethod<Map<dynamic, dynamic>>('availableCameras');
      if (cameras == null) return null;
      return cameras.map((Map<dynamic, dynamic> camera) {
        return Cameras(
            name: camera['name'] as String,
            lensFacing: _getCameraLensFacing(camera['lensFacing'] as String));
      }).toList();
    } on PlatformException catch (e) {
      log(e);
    }
    return null;
  }

  void disposeCameras() {
    _streamSubscription?.cancel();
    _eventChannel = null;
    if (textureId == null) return;
    curiosityChannel.invokeMethod<dynamic>(
        'disposeCameras', <String, int>{'textureId': textureId!});
  }

  CameraLensFacing _getCameraLensFacing(String lensFacing) {
    switch (lensFacing) {
      case 'back':
        return CameraLensFacing.back;
      case 'front':
        return CameraLensFacing.front;
      case 'external':
        return CameraLensFacing.external;
      default:
        return CameraLensFacing.external;
    }
  }
}

class ScanResult {
  ScanResult(this.code, this.type);

  ScanResult.fromJson(Map<dynamic, dynamic> json) {
    code = json['code'] as String;
    type = json['type'] as String;
  }

  String? code;
  String? type;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['type'] = type;
    return data;
  }
}

class Cameras {
  Cameras({required this.name, required this.lensFacing});

  final String name;
  final CameraLensFacing lensFacing;
}

/// 以下方法可以配合 camera 组件 做二维码或条形码识别
Future<ScanResult?> scanImagePath(String path) async {
  try {
    final Map<dynamic, dynamic>? data = await curiosityChannel
        .invokeMethod('scanImagePath', <String, String>{'path': path});
    if (data != null) return ScanResult.fromJson(data);
  } on PlatformException catch (e) {
    log(e);
  }
  return null;
}

Future<ScanResult?> scanImageUrl(String url) async {
  try {
    final Map<dynamic, dynamic>? data = await curiosityChannel
        .invokeMethod('scanImageUrl', <String, String>{'url': url});
    if (data != null) return ScanResult.fromJson(data);
  } on PlatformException catch (e) {
    log(e);
  }
  return null;
}

Future<ScanResult?> scanImageMemory(Uint8List uint8list) async {
  try {
    final Map<dynamic, dynamic>? data = await curiosityChannel.invokeMethod(
        'scanImageMemory', <String, Uint8List>{'uint8list': uint8list});
    if (data != null) return ScanResult.fromJson(data);
  } on PlatformException catch (e) {
    log(e);
  }
  return null;
}
