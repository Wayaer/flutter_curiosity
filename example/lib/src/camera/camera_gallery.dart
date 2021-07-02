import 'dart:io';

import 'package:curiosity/main.dart';
import 'package:curiosity/src/camera/camera_scan.dart';
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
  String path = '';

  @override
  void initState() {
    super.initState();
    getAppPath().then((AppPathModel? value) {
      log(value?.homeDirectory);
      log(value?.documentDirectory);
      log(value?.libraryDirectory);
      log(value?.cachesDirectory);
      log(value?.temporaryDirectory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
        appBar: AppBarText('Camera and Gallery'),
        body: Universal(isScroll: true, children: <Widget>[
          ElevatedText(onPressed: scan, text: '扫码'),
          ElevatedText(onPressed: systemGallery, text: '打开系统相册'),
          ElevatedText(onPressed: systemCamera, text: '打开系统相机'),
          ElevatedText(onPressed: systemAlbum, text: '打开IOS系统相薄'),
          ElevatedText(onPressed: scanImage, text: '官方相机扫码'),
          ElevatedText(
              onPressed: () => push(FileImageScanPage()), text: '识别图片二维码'),
          const SizedBox(height: 20),
          Container(
              padding: const EdgeInsets.only(top: 100),
              child: const ScannerBox(
                  borderColor: Colors.blue,
                  scannerColor: Colors.blue,
                  boxSize: Size(200, 200))),
          showText('path', path),
          if (path.isNotEmpty)
            Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                child: Image.file(File(path)))
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
        path = value;
        pop();
        setState(() {});
      }));
    } else {
      openAppSettings();
    }
  }

  Future<void> systemGallery() async {
    final String? data = await openSystemGallery();
    path = data.toString();
    setState(() {});
  }

  Future<void> systemCamera() async {
    if (!isMobile) return;
    if (await requestPermissions(Permission.camera, '使用相机')) {
      final String? data = await openSystemCamera();
      path = data.toString();
      setState(() {});
    } else {
      showToast('未获取相机权限');
    }
  }

  Future<void> systemAlbum() async {
    if (!isIOS) return;
    if (await requestPermissions(Permission.photos, '使用相册')) {
      final String? data = await openSystemAlbum();
      path = data.toString();
      setState(() {});
    } else {
      showToast('未获取相册权限');
    }
  }
}
