import 'package:camera/camera.dart';
import 'package:curiosity/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({Key? key, required this.scanResult}) : super(key: key);

  //// 扫描结果回调
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

  @override
  void initState() {
    super.initState();
    addPostFrameCallback((Duration duration) {
      initCamera();
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
    controller =
        CameraController(description, ResolutionPreset.max, enableAudio: false);
    await controller!.initialize();
    setState(() {});
    time = DateTime.now().millisecondsSinceEpoch;
    startImageStream();
  }

  void startImageStream() {
    hasImageStream = true;
    controller!.startImageStream((CameraImage image) {
      log('返回相机图片流');
      if (hasImageStream) controller!.stopImageStream();
      hasImageStream = false;
      log('controller!.stopImageStream();');
      if (image.planes.isEmpty) {
        log('startImageStream == image.planes==null');
        return;
      }
      if (image.planes[0].bytes.isEmpty) {
        log('startImageStream == image.planes[0].bytes.isEmpty');
        return;
      }
      if (image.format.group != ImageFormatGroup.yuv420) {
        log('startImageStream == image.format.group != ImageFormatGroup.yuv420');
        return;
      }
      log('开始解析图片流');
      scanImageMemory(image.planes[0].bytes, onEventListen: (ScanResult? data) {
        if (data != null) {
          log('解析的二维码数据: ' + data.code);
        } else {
          log('重新解析图片流');
          5.seconds.delayed(startImageStream);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Container();
    if (controller != null && controller?.value.previewSize != null) {
      log('相机  aspectRatio ' + controller!.value.aspectRatio.toString());
      child = CameraPreview(controller!);
    }
    return OverlayScaffold(
        backgroundColor: Colors.black, body: Center(child: child));
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }
}

class UrlImageScanPage extends StatefulWidget {
  @override
  _UrlImageScanPageState createState() => _UrlImageScanPageState();
}

class _UrlImageScanPageState extends State<UrlImageScanPage> {
  TextEditingController controller = TextEditingController();
  String code = '';
  String type = '';

  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
        appBar: AppBarText('San url image'),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: <Widget>[
          Container(
              margin: const EdgeInsets.all(20),
              child: TextField(
                  decoration: InputDecoration(
                    hintText: '请输入Url',
                    helperText: '务必输入正确的url地址',
                    focusedBorder: inputBorder(Colors.blueAccent),
                    enabledBorder: inputBorder(Colors.blueAccent),
                    disabledBorder: inputBorder(Colors.grey),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  controller: controller)),
          ElevatedText(onPressed: () => scan(), text: '识别二维码'),
          showText('code', code),
          showText('type', type),
        ]);
  }

  Future<void> scan() async {
    if (controller.text.isEmpty) return showToast('请输入Url');
    final ScanResult? data = await scanImageUrl(controller.text);
    if (data != null) {
      code = data.code;
      type = data.type;
      setState(() {});
    }
  }

  InputBorder inputBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(width: 1, color: color));
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
          ElevatedText(onPressed: () => scan(), text: '识别'),
          showText('code', code),
          showText('type', type),
        ]);
  }

  Future<void> scan() async {
    if (path.isEmpty) return showToast('请选择图片');
    final ScanResult? data = await scanImagePath(path);
    if (data != null) {
      code = data.code;
      type = data.type;
      setState(() {});
    }

    if (await requestPermissions(Permission.storage, '读取文件')) {
      final ScanResult? data = await scanImagePath(path);
      if (data != null) {
        code = data.code;
        type = data.type;
        setState(() {});
      }
    }
  }

  Future<void> openGallery() async {
    final String? data = await openSystemGallery();
    showToast(data.toString());
    path = data.toString();
    setState(() {});
  }
}
