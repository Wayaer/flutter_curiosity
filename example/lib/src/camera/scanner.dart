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
    controller = CameraController(description, ResolutionPreset.high);
    await controller!.initialize();
    setState(() {});
    time = DateTime.now().millisecondsSinceEpoch;
    controller!.startImageStream((CameraImage image) async {
      final int now = DateTime.now().millisecondsSinceEpoch;
      if ((now - time) < 2000) return;
      if (image.planes.isEmpty) return;
      if (image.planes[0].bytes.isEmpty) return;
      if (image.format.group != ImageFormatGroup.yuv420) return;

      log(image.planes[0].bytes);
      final ScanResult? data = await scanImageMemory(image.planes[0].bytes);
      if (data != null) {
        showToast(data.code);
        print(data.toJson());
        controller!.stopImageStream();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Container();
    if (controller != null && controller?.value.previewSize != null) {
      log(controller!.value.aspectRatio);
      final Size size = controller!.value.previewSize!;
      child = AspectRatio(
          aspectRatio: size.height / size.width,
          child: CameraPreview(controller!));
    }
    return OverlayScaffold(
        backgroundColor: Colors.black, body: Center(child: child));
  }

  @override
  void dispose() {
    super.dispose();
    controller?.stopImageStream();
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
        appBar: const AppBarText('San url image'),
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
        appBar: const AppBarText('San file image'),
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
