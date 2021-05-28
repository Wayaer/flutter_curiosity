import 'package:curiosity/main.dart';
import 'package:curiosity/src/camera/scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraGalleryPage extends StatefulWidget {
  @override
  _CameraGalleryPageState createState() => _CameraGalleryPageState();
}

class _CameraGalleryPageState extends State<CameraGalleryPage> {
  bool san = true;
  String text = '';

  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
        appBar: AppBarText('Camera and Gallery'),
        body: Universal(isScroll: true, children: <Widget>[
          ElevatedText(onPressed: scan, text: '扫码'),
          ElevatedText(onPressed: systemGallery, text: '打开系统相册'),
          ElevatedText(onPressed: systemCamera, text: '打开系统相机'),
          ElevatedText(onPressed: scanImage, text: '相机识别二维码'),
          ElevatedText(
              onPressed: () => push(UrlImageScanPage()), text: '识别Url二维码'),
          ElevatedText(
              onPressed: () => push(FileImageScanPage()), text: '识别本地图片二维码'),
          const SizedBox(height: 20),
          Container(
              padding: const EdgeInsets.only(top: 100),
              child: const ScannerBox(
                  borderColor: Colors.blue,
                  scannerColor: Colors.blue,
                  boxSize: Size(200, 200))),
          showText('path', text),
        ]));
  }

  Future<void> scanImage() async {
    if (!isMobile) return;
    final bool permission = await requestPermissions(Permission.camera, '相机') &&
        await requestPermissions(Permission.storage, '手机存储');
    if (permission) {
      push(CameraScanPage());
    } else {
      openAppSettings();
    }
  }

  Future<void> scan() async {
    if (!isMobile) return;
    final bool permission = await requestPermissions(Permission.camera, '相机') &&
        await requestPermissions(Permission.storage, '手机存储');
    if (permission) {
      push(ScannerPage(scanResult: (String value) {
        text = value;
        pop();
        setState(() {});
      }));
    } else {
      openAppSettings();
    }
  }

  Future<void> systemGallery() async {
    final String? data = await openSystemGallery();
    showToast(data.toString());
    text = data.toString();
    setState(() {});
  }

  Future<void> systemCamera() async {
    if (!isMobile) return;
    if (await requestPermissions(Permission.camera, '使用相机')) {
      final String? data = await openSystemCamera();
      showToast(data.toString());
      text = data.toString();
      setState(() {});
    } else {
      showToast('未获取相机权限');
    }
  }
}
