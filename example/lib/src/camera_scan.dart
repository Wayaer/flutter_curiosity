import 'dart:io';

import 'package:camera/camera.dart';
import 'package:curiosity/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key}) : super(key: key);

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool san = true;
  String? code;

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        appBar: AppBarText('Camera and Scanner'),
        body: Universal(isScroll: true, children: <Widget>[
          ElevatedText(
              onPressed: () => scan(<ScanType>[
                    ScanType.qrCode,
                    ScanType.ean8,
                    ScanType.ean13,
                    ScanType.upcA,
                    ScanType.upcE,
                  ]),
              text: '扫码(识别支持全部)'),
          ElevatedText(onPressed: scan, text: '扫码(只识别二维码)'),
          ElevatedText(onPressed: scanImage, text: '官方相机扫码'),
          ElevatedText(
              onPressed: () => push(_FileImageScanPage()), text: '识别图片二维码'),
          const SizedBox(height: 20),
          SizedBox.fromSize(
              size: const Size(300, 300),
              child: const ScannerBox(
                  scannerSize: Size(200, 200),
                  borderColor: Colors.blue,
                  scannerColor: Colors.blue)),
          showText('code', code),
        ]));
  }

  Future<void> scanImage() async {
    if (!isMobile) return;
    final bool permission = await getPermission(Permission.camera) &&
        await getPermission(Permission.storage);
    if (permission) {
      push(_CameraScanPage());
    } else {
      openAppSettings();
    }
  }

  Future<void> scan([List<ScanType>? scanTypes]) async {
    if (!isMobile) return;
    final bool permission = await getPermission(Permission.camera) &&
        await getPermission(Permission.storage);
    if (permission) {
      push(ScannerView(
          scanTypes: scanTypes,
          scanResult: (String value) {
            code = value;
            pop();
            setState(() {});
          }));
    } else {
      openAppSettings();
    }
  }
}

class _CameraScanPage extends StatefulWidget {
  @override
  _CameraScanPageState createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<_CameraScanPage> {
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
      log(value.runtimeType);
      if (value != null && hasImageStream) {
        final ScanResult scanResult =
            ScanResult.fromJson(value as Map<dynamic, dynamic>);
        showToast(scanResult.code ?? '');
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
    return ExtendedScaffold(
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

class _FileImageScanPage extends StatefulWidget {
  @override
  _FileImageScanPageState createState() => _FileImageScanPageState();
}

class _FileImageScanPageState extends State<_FileImageScanPage> {
  String? path;
  String code = '';
  String type = '';

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        appBar: AppBarText('San file image'),
        padding: const EdgeInsets.all(20),
        isScroll: true,
        children: <Widget>[
          showText('code', code),
          showText('type', type),
          ElevatedText(onPressed: () => openGallery(), text: '选择图片'),
          ElevatedText(onPressed: () => scanPath(), text: '识别(使用Path识别)'),
          ElevatedText(onPressed: () => scanByte(), text: '识别(从内存中识别)'),
          showText('path', path),
          if (path != null && path!.isNotEmpty)
            Container(
                width: double.infinity,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                child: Image.file(File(path!))),
        ]);
  }

  Future<void> scanPath() async {
    if (path == null || path!.isEmpty) return showToast('请选择图片');
    if (await getPermission(Permission.storage)) {
      final ScanResult? data = await scanImagePath(path!);
      code = data?.code ?? '未识别';
      type = data?.type ?? '未识别';
      setState(() {});
    }
  }

  Future<void> scanByte() async {
    if (path == null || path!.isEmpty) return showToast('请选择图片');
    if (await getPermission(Permission.storage)) {
      final File file = File(path!);
      final ScanResult? data = await scanImageByte(file.readAsBytesSync());
      code = data?.code ?? '未识别';
      type = data?.type ?? '未识别';
      setState(() {});
    }
  }

  Future<void> openGallery() async {
    final String? data = await openSystemGallery();
    path = data;
    setState(() {});
  }
}
