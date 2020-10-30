import 'package:curiosity/main.dart';
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
  List<AssetMedia> listAssetMedia = <AssetMedia>[];
  String text = '';

  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
        appBar: AppBar(title: const Text('Camera and Gallery')),
        body: Universal(isScroll: true, children: <Widget>[
          RaisedButton(onPressed: () => scan(context), child: const Text('扫码')),
          RaisedButton(
              onPressed: () => selectImage(), child: const Text('图片选择')),
          RaisedButton(
              onPressed: () => deleteCacheDir(), child: const Text('清除图片选择缓存')),
          RaisedButton(
              onPressed: () => systemGallery(), child: const Text('打开系统相册')),
          RaisedButton(
              onPressed: () => systemCamera(), child: const Text('打开系统相机')),
          const SizedBox(height: 20),
          Visibility(
              visible: text != null && text.isNotEmpty,
              child: showText('path', text)),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: listAssetMedia
                  .map((AssetMedia value) =>
                      showText(value.path, value.fileName))
                  .toList()),
        ]));
  }

  Future<void> selectImage() async {
    final PicturePickerOptions options = PicturePickerOptions();
    options.pickerSelectType = 0;
    options.isGif = true;
    options.isCamera = true;
    options.freeStyleCropEnabled = true;
    options.originalPhoto = true;
    options.maxSelectNum = 4;
    listAssetMedia = await openImagePicker(options);
    setState(() {});
  }

  Future<dynamic> deleteCacheDir() async {
    final String data = await deleteCacheDirFile();
    showToast(data);
  }

  Future<void> scan(BuildContext context) async {
    final bool permission = await Utils.requestPermissions(
            Permission.camera, '相机', showAlert: false) &&
        await Utils.requestPermissions(Permission.storage, '手机存储',
            showAlert: false);
    if (permission) {
      showBottomPagePopup<dynamic>(widget: ScannerPage(
        scanResult: (String value) {
          text = value;
          pop();
          setState(() {});
        },
      ));
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
