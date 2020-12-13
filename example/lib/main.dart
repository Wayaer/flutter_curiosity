import 'package:curiosity/src/camera/camera_gallery.dart';
import 'package:curiosity/src/get_info.dart';
import 'package:curiosity/src/jump_setting.dart';
import 'package:curiosity/src/share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_waya/flutter_waya.dart';

void main() {
  runApp(GlobalWidgetsApp(
      debugShowCheckedModeBanner: false, title: 'Curiosity', home: App()));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Flutter Curiosity Plugin Example'),
      ),
      body: Universal(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
              onPressed: () => push(widget: SharePage()),
              child: const Text('分享')),
          RaisedButton(
              onPressed: () => push(widget: GetInfoPage()),
              child: const Text('获取信息')),
          RaisedButton(
              onPressed: () => push(widget: JumpSettingPage()),
              child: const Text('跳转设置')),
          RaisedButton(
              onPressed: () => push(widget: CameraGalleryPage()),
              child: const Text('相机和图库')),
        ],
      ),
    );
  }
}

Widget showText(dynamic key, dynamic value) {
  return Visibility(
      visible: value != null &&
          value.toString().isNotEmpty &&
          value.toString() != 'null',
      child: Container(
          margin: const EdgeInsets.all(10),
          child: Text(key.toString() + ' = ' + value.toString())));
}
