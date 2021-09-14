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
  List<String> paths = <String>[];
  bool needShow = false;

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        appBar: AppBarText('Camera and Gallery'),
        body: Universal(isScroll: true, children: <Widget>[
          const SizedBox(height: 12),
          if (isMobile) ...<Widget>[
            ElevatedText(onPressed: systemGallery, text: '打开系统相册'),
            ElevatedText(onPressed: systemCamera, text: '打开系统相机'),
            if (isIOS) ElevatedText(onPressed: systemAlbum, text: '打开IOS系统相薄'),
          ],
          const SizedBox(height: 20),
          Column(
              children: paths.builder((String path) => needShow
                  ? Column(children: <Widget>[
                      ShowText('path', path),
                      if (path.isNotEmpty)
                        Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(20),
                            child: Image.file(File(path)))
                    ])
                  : ShowText('path', path)))
        ]));
  }

  Future<void> systemGallery() async {
    bool hasPermission = false;
    if (isAndroid) hasPermission = await getPermission(Permission.storage);
    if (isIOS) hasPermission = true;
    if (hasPermission) {
      final String? data = await Curiosity().gallery.openSystemGallery();
      if (data != null) {
        needShow = true;
        paths = <String>[data];
        setState(() {});
      }
    } else {
      showToast('未获取相册权限');
    }
  }

  Future<void> systemCamera() async {
    if (!isMobile) return;
    bool hasPermission = false;
    if (isAndroid)
      hasPermission = await getPermission(Permission.storage) &&
          await getPermission(Permission.camera);
    if (isIOS) hasPermission = await getPermission(Permission.camera);
    if (hasPermission) {
      final String? data = await Curiosity().gallery.openSystemCamera();
      if (data != null) {
        needShow = true;
        paths = <String>[data];
        setState(() {});
      }
    } else {
      showToast('未获取相机权限');
    }
  }

  Future<void> systemAlbum() async {
    if (!isIOS) return;
    bool hasPermission = false;
    if (isAndroid) hasPermission = await getPermission(Permission.storage);
    if (isIOS) hasPermission = true;
    if (hasPermission) {
      final String? data = await Curiosity().gallery.openSystemAlbum();
      if (data != null) {
        needShow = true;
        paths = <String>[data];
        setState(() {});
      }
    } else {
      showToast('未获取相册权限');
    }
  }
}
