import 'dart:io';

import 'package:camera/camera.dart';
import 'package:curiosity/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({Key? key, required this.scanResult}) : super(key: key);

  final ValueChanged<String> scanResult;

  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
        backgroundColor: Colors.black,
        body: Center(child: ScannerView(scanResult: scanResult)));
  }
}

class CameraScanPage extends StatefulWidget {
  @override
  _CameraScanPageState createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  CameraController? controller;
  int time = 0;
  bool hasImageStream = false;
  CuriosityEvent? event;
  int currentTime = 0;

  @override
  void initState() {
    super.initState();
    initEvent();
    addPostFrameCallback((Duration duration) {
      initCamera();
    });
  }

  Future<void> initEvent() async {
    event = CuriosityEvent.instance;
    final bool state = await event!.initialize();
    if (!state) return;
    event!.addListener((dynamic value) {
      log('收到了原生发来的消息== $value');
      if (value != null && hasImageStream) {
        final ScanResult scanResult =
            ScanResult.fromJson(value as Map<dynamic, dynamic>);
        showToast(scanResult.code);
      } else {
        showToast(value.toString());
      }
    });
  }

  Future<void> initCamera() async {
    final List<CameraDescription> cameras = await availableCameras();
    CameraDescription? description;
    for (final CameraDescription element in cameras) {
      if (element.lensDirection == CameraLensDirection.back)
        description = element;
    }
    if (description == null) return;
    controller = CameraController(description, ResolutionPreset.high,
        enableAudio: false);
    await controller!.initialize();
    setState(() {});
    time = DateTime.now().millisecondsSinceEpoch;
    startImageStream();
  }

  void startImageStream() {
    hasImageStream = true;
    currentTime = DateTime.now().millisecond;
    controller?.startImageStream((CameraImage image) {
      if ((DateTime.now().millisecond - currentTime) > 400) {
        /// 每500毫秒解析一次
        if (image.planes.isEmpty || image.planes[0].bytes.isEmpty) return;

        if (isAndroid && image.format.group != ImageFormatGroup.yuv420) return;

        return scanImageYUV(
            uint8list: image.planes[0].bytes,
            width: image.width,
            height: image.height);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Container();
    if (controller != null) child = CameraPreview(controller!);
    return OverlayScaffold(
        backgroundColor: Colors.black, body: Center(child: child));
  }

  @override
  void deactivate() {
    event?.dispose();
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
    controller = null;
  }
}

class FileImageScanPage extends StatefulWidget {
  @override
  _FileImageScanPageState createState() => _FileImageScanPageState();
}

class _FileImageScanPageState extends State<FileImageScanPage> {
  String path = '';
  String code = '';
  String type = '';

  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
        appBar: AppBarText('San file image'),
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          ElevatedText(onPressed: () => openGallery(), text: '选择图片'),
          showText('path', path),
          ElevatedText(onPressed: () => scanPath(), text: '识别(使用Path识别)'),
          ElevatedText(onPressed: () => scanByte(), text: '识别(从内存中识别)'),
          showText('code', code),
          showText('type', type),
        ]);
  }

  Future<void> scanPath() async {
    if (path.isEmpty) return showToast('请选择图片');
    if (await requestPermissions(Permission.storage, '读取文件')) {
      final ScanResult? data = await scanImagePath(path);
      if (data == null) return;
      code = data.code;
      type = data.type;
      setState(() {});
    }
  }

  Future<void> scanByte() async {
    if (path.isEmpty) return showToast('请选择图片');
    if (await requestPermissions(Permission.storage, '读取文件')) {
      final File file = File(path);
      final ScanResult? data = await scanImageByte(file.readAsBytesSync());
      if (data == null) return;
      code = data.code;
      type = data.type;
      setState(() {});
    }
  }

  Future<void> openGallery() async {
    final String? data = await openSystemGallery();
    path = data.toString();
    setState(() {});
  }
}
