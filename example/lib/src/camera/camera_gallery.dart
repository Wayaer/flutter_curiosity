import 'package:curiosity/main.dart';
import 'package:curiosity/src/camera/scan.dart';
import 'package:curiosity/src/utils/utils.dart';
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
        appBar: AppBar(title: const Text('Camera and Gallery')),
        body: Universal(isScroll: true, children: <Widget>[
          RaisedButton(onPressed: () => scan(context), child: const Text('扫码')),
          RaisedButton(
              onPressed: () => systemGallery(), child: const Text('打开系统相册')),
          RaisedButton(
              onPressed: () => systemCamera(), child: const Text('打开系统相机')),
          RaisedButton(
              onPressed: () => scanImage(context),
              child: const Text('相机识别二维码')),
          RaisedButton(
              onPressed: () => push(widget: UrlImageScanPage()),
              child: const Text('识别Url二维码')),
          RaisedButton(
              onPressed: () => push(widget: FileImageScanPage()),
              child: const Text('识别本地图片二维码')),
          const SizedBox(height: 20),
          showText('path', text),
        ]));
  }

  Future<void> scanImage(BuildContext context) async {
    final bool permission =
        await Utils.requestPermissions(Permission.camera, '相机') &&
            await Utils.requestPermissions(Permission.storage, '手机存储');
    if (permission) {
      showBottomPagePopup<dynamic>(widget: CameraScanPage());
    } else {
      openAppSettings();
    }
  }

  Future<void> scan(BuildContext context) async {
    final bool permission =
        await Utils.requestPermissions(Permission.camera, '相机') &&
            await Utils.requestPermissions(Permission.storage, '手机存储');
    if (permission) {
      showBottomPagePopup<dynamic>(
          widget: ScannerPage(scanResult: (String value) {
        text = value;
        pop();
        setState(() {});
      }));
    } else {
      openAppSettings();
    }
  }

  Future<void> systemGallery() async {
    final String data = await openSystemGallery;
    showToast(data.toString());
    text = data;
    setState(() {});
  }

  Future<void> systemCamera() async {
    if (await Utils.requestPermissions(Permission.camera, '使用相机')) {
      final String data = await openSystemCamera();
      showToast(data.toString());
      text = data;
      setState(() {});
    } else {
      showToast('未获取相机权限');
    }
  }
}
