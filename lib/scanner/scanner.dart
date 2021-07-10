import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_curiosity/constant/styles.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/tools/internal.dart';

/// 基于原始扫描预览
/// 使用简单
class ScannerView extends StatefulWidget {
  ScannerView({
    Key? key,
    CameraLensFacing? lensFacing,
    Color? flashOnColor,
    Color? flashOffColor,
    List<ScanType>? scanTypes,
    this.topRatio = 0.3,
    this.leftRatio = 0.1,
    this.widthRatio = 0.8,
    this.heightRatio = 0.4,
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
        flashOffColor = flashOffColor ?? Colors.white60,
        scanTypes = scanTypes ?? <ScanType>[ScanType.qrCode],
        assert(leftRatio * 2 + widthRatio == 1),
        assert(topRatio * 2 + heightRatio == 1),
        super(key: key);

  /// 相机位置
  final CameraLensFacing lensFacing;

  /// 识别的二维码类型
  final List<ScanType>? scanTypes;

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
    WidgetsBinding.instance?.addObserver(this);
    WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) =>
        Timer(const Duration(milliseconds: 300), initController));
  }

  Future<void> initController() async {
    controller = ScannerController(
        scanTypes: widget.scanTypes,
        resolution: widget.resolution ?? CameraResolution.medium);
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
    CameraOptions? camera;
    final List<CameraOptions>? cameras = await controller!.availableCameras();
    print(cameras);
    if (cameras == null) return;
    for (final CameraOptions cameraInfo in cameras) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller?.textureId == null) return Container();
    final Widget child = Scanner(controller: controller!);
    final List<Widget> children = <Widget>[];
    children.add(Align(
        alignment: Alignment.center,
        child: AspectRatio(
            aspectRatio: controller!.previewHeight! / controller!.previewWidth!,
            child: child)));
    if (widget.scannerBox) children.add(previewBox);
    children.add(Container(
      margin: const EdgeInsets.only(bottom: 20),
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
          onTap: openFlash,
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Icon(Icons.highlight,
                size: 30,
                color: flash ? widget.flashOnColor : widget.flashOffColor),
            Text(widget.flashText ?? '轻触点亮',
                style: BaseTextStyle(
                    color: flash ? widget.flashOnColor : widget.flashOffColor))
          ])),
    ));
    if (widget.child != null) children.add(widget.child!);
    return Stack(children: children);
  }

  Widget get previewBox {
    final Size size = getWindowSize;
    final double w = size.width * widget.widthRatio;
    final double h = size.height * widget.heightRatio;
    return ScannerBox(
        scannerSize: Size(w, h),
        borderColor: widget.borderColor,
        scannerColor: widget.scannerColor,
        hornStrokeWidth: widget.hornStrokeWidth,
        scannerStrokeWidth: widget.scannerStrokeWidth);
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
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    controller?.dispose();
    controller = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller != null) {
      if (state == AppLifecycleState.resumed) {
        initController();
      } else {
        controller!.dispose();
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

enum ScanType {
  /// Android ios
  upcE,
  ean13,
  ean8,
  code39,
  code93,
  code128,
  qrCode,
  aztec,
  dataMatrix,
  pdf417,

  /// only ios
  code39Mod43,
  itf14,
  interleaved2of5,
  dogBody,
  catBody,
  humanBody,

  /// only android
  upcA,
  codaBar,
  itf,
  rss14,
  rssExpanded,
  maxICode,
  upcEanExtension
}

class ScannerController extends ChangeNotifier {
  ScannerController({
    CameraResolution? resolution,
    List<ScanType>? scanTypes,
    this.topRatio = 0.3,
    this.camera,
    this.leftRatio = 0.1,
    this.widthRatio = 0.8,
    this.heightRatio = 0.4,
  })  : resolution = resolution ?? CameraResolution.veryHigh,
        scanTypes = scanTypes ?? <ScanType>[ScanType.qrCode],
        assert(leftRatio * 2 + widthRatio == 1),
        assert(topRatio * 2 + heightRatio == 1);

  /// 识别区域距离顶部占整个高度的比值
  final double topRatio;

  /// 识别区域距离左边占整个宽度的比值
  final double leftRatio;

  /// 识别区域宽度的比值
  final double widthRatio;

  /// 识别区域高度的比值
  final double heightRatio;

  /// 相机
  final CameraResolution resolution;

  /// 识别码的类型 默认只识别二维码
  /// 识别类型越少，识别速度越快
  final List<ScanType> scanTypes;

  /// 预览的相机信息
  CameraOptions? camera;

  /// 扫描结果
  ScanResult? scanResult;

  /// 外接纹理id
  int? textureId;

  /// 相机预览区域的宽度
  double? previewWidth;

  /// 相机预览区域的高度
  double? previewHeight;

  /// 相机状态
  String? cameraState;

  /// 初始化相机
  Future<void> initialize({CameraOptions? cameras}) async {
    if (cameras != null) camera = cameras;
    if (camera == null) return;
    try {
      final Map<String, dynamic> arguments = <String, dynamic>{
        'cameraId': camera!.name,
        'resolutionPreset': resolution.toString().split('.')[1],
        'topRatio': topRatio,
        'leftRatio': leftRatio,
        'widthRatio': widthRatio,
        'heightRatio': heightRatio,
        'scanTypes': scanTypes
            .map((ScanType e) => e.toString().split('.')[1])
            .toSet()
            .toList(),
      };

      /// 先初始化 消息通道
      final CuriosityEvent event = CuriosityEvent.instance;
      final bool eventState = await event.initialize();

      /// 初始化相机组件
      final Map<String, dynamic>? reply = await curiosityChannel
          .invokeMapMethod<String, dynamic>('initializeCameras', arguments);
      if (reply == null) return;
      textureId = reply['textureId'] as int;
      cameraState = reply['cameraState'] as String?;
      previewWidth = double.parse(reply['previewWidth'].toString());
      previewHeight = double.parse(reply['previewHeight'].toString());
      if (eventState) {
        event.addListener((dynamic data) {
          if (data == null) return;
          scanResult = ScanResult.fromJson(data as Map<dynamic, dynamic>);
          notifyListeners();
        });
      }
    } catch (e) {
      log('initializeCameras Exception');
      log(e);
    }
  }

  /// 打开/关闭闪光灯
  Future<bool?> setFlashMode(bool status) =>
      curiosityChannel.invokeMethod('setFlashMode', status);

  /// 获取可用的相机
  Future<List<CameraOptions>> availableCameras() async {
    try {
      final List<Map<dynamic, dynamic>>? cameras = await curiosityChannel
          .invokeListMethod<Map<dynamic, dynamic>>('availableCameras');
      if (cameras == null) return <CameraOptions>[];
      return cameras
          .map((Map<dynamic, dynamic> camera) => CameraOptions(
              name: camera['name'] as String,
              lensFacing: _getCameraLensFacing(camera['lensFacing'] as String)))
          .toList();
    } on PlatformException catch (e) {
      log(e);
    }
    return <CameraOptions>[];
  }

  /// 销毁相机组件

  @override
  Future<void> dispose() async {
    if (textureId == null) return;
    await curiosityChannel.invokeMethod<bool>('disposeCameras', textureId);
    super.dispose();
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

/// 相机信息
class CameraOptions {
  CameraOptions({required this.name, required this.lensFacing});

  String name;
  CameraLensFacing lensFacing;
}

/// 扫码识别数据模型
class ScanResult {
  ScanResult.fromJson(Map<dynamic, dynamic> json) {
    code = json['code'] as String?;
    type = json['type'] as String?;
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
