import 'package:curiosity/ScanCodePage.dart';
import 'package:curiosity/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  runApp(OverlayMaterial(
    debugShowCheckedModeBanner: false,
    title: 'Curiosity',
    home: App(),
  ));
}

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

class AppState extends State<App> {
  bool san = true;
  StateSetter textSetState;
  List<AssetMedia> list = List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Flutter Curiosity Plugin app'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(),
          StatefulBuilder(
            builder: (BuildContext context, StateSetter state) {
              textSetState = state;
              return Column(children: showText());
            },
          ),
          RaisedButton(onPressed: () => scan(context), child: Text('扫码')),
          RaisedButton(onPressed: () => select(), child: Text('图片选择')),
          RaisedButton(
              onPressed: () => openSystemGallery(), child: Text('打开系统相册')),
          RaisedButton(
              onPressed: () => openSystemCamera(), child: Text('打开系统相机')),
          RaisedButton(onPressed: () => shareText(), child: Text('分享文字')),
          RaisedButton(onPressed: () => shareImage(), child: Text('分享图片')),
          RaisedButton(onPressed: () => shareImages(), child: Text('分享多张图片')),
          RaisedButton(onPressed: () => getGPS(), child: Text('获取gps状态')),
          RaisedButton(
              onPressed: () => NativeTools.jumpGPSSetting(),
              child: Text('跳转GPS设置')),
        ],
      ),
    );
  }

  openSystemGallery() async {
    var data = await NativeTools.openSystemGallery();
    showToast(data.toString());
  }

  openSystemCamera() async {
    var data = await NativeTools.openSystemCamera();
    showToast(data);
  }

  shareText() {
    NativeTools.systemShare(
        title: '分享图片', content: '分享几个文字', shareType: ShareType.text);
  }

  shareImage() {
    if (list.length == 0) {
      showToast('请先选择图片');
      return;
    }
    NativeTools.systemShare(
        title: '分享图片', content: list[0].path, shareType: ShareType.image);
  }

  shareImages() {
    if (list.length == 0) {
      showToast('请先选择图片');
      return;
    }
    List<String> listPath = [];
    listPath.add(list[0].path);
    listPath.add(list[0].path);
    NativeTools.systemShare(
        title: '分享图片', imagesPath: listPath, shareType: ShareType.images);
  }

  getGPS() async {
    var data = await NativeTools.getGPSStatus();
    showToast(data.toString());
  }

  List<Widget> showText() {
    List<Widget> widget = List();
    list.map((value) {
      widget.add(Text(value.path + '==' + value.fileName));
    }).toList();
    return widget;
  }

  scan(BuildContext context) async {
    var permission = await Utils.requestPermissions(Permission.camera, '相机',
            showAlert: false) &&
        await Utils.requestPermissions(Permission.storage, '手机存储',
            showAlert: false);
    if (permission) {
      showCupertinoModalPopup(
          context: context, builder: (context) => ScanCodePage());
    } else {
      openAppSettings();
    }
  }

  select() async {
    PicturePickerOptions options = PicturePickerOptions();
    list = await PicturePicker.openPicker(options);
    setState(() {});
  }
}
