import 'dart:io';

import 'package:curiosity/main.dart';
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
  String? path;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        appBar: AppBarText('Camera and Gallery'),
        body: Universal(isScroll: true, children: <Widget>[
          ElevatedText(onPressed: systemGallery, text: '打开系统相册'),
          ElevatedText(onPressed: systemCamera, text: '打开系统相机'),
          if (isIOS) ElevatedText(onPressed: systemAlbum, text: '打开IOS系统相薄'),
          const SizedBox(height: 20),
          Container(
              padding: const EdgeInsets.only(top: 100),
              child: const ScannerBox(
                  borderColor: Colors.blue,
                  scannerColor: Colors.blue,
                  boxSize: Size(200, 200))),
          showText('path', path),
          if (path != null && path!.isNotEmpty)
            Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                child: Image.file(File(path!)))
        ]));
  }

  Future<void> systemGallery() async {
    if (await getPermission(Permission.photos)) {
      final String? data = await openSystemGallery();
      print('systemGallery : $data');
      path = data;
      setState(() {});
    } else {
      showToast('未获取相册权限');
    }
  }

  Future<void> systemCamera() async {
    if (!isMobile) return;
    if (await getPermission(Permission.camera)) {
      final String? data = await openSystemCamera();
      print('systemCamera : $data');
      path = data;
      setState(() {});
    } else {
      showToast('未获取相机权限');
    }
  }

  Future<void> systemAlbum() async {
    if (!isIOS) return;
    if (await getPermission(Permission.photos)) {
      final String? data = await openSystemAlbum();
      print('systemAlbum : $data');
      path = data;
      setState(() {});
    } else {
      showToast('未获取相册权限');
    }
  }
}
