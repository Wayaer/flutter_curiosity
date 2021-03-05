import 'dart:ui';

import 'package:curiosity/src/camera/camera_gallery.dart';
import 'package:curiosity/src/get_info.dart';
import 'package:curiosity/src/jump_setting.dart';
import 'package:curiosity/src/share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //// 关闭辅助触控
  window.onSemanticsEnabledChanged = () {};
  RendererBinding.instance!.setSemanticsEnabled(false);

  print('isWeb');
  print(isWeb);
  print('isMacOS');
  print(isMacOS);
  print('isAndroid');
  print(isAndroid);
  print('isIOS');
  print(isIOS);
  print('isMobile');
  print(isMobile);
  print('isDesktop');
  print(isDesktop);

  runApp(MaterialApp(
    navigatorKey: navigatorKey,
    debugShowCheckedModeBanner: false,
    title: 'Curiosity',
    home: App(),
  ));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Flutter Curiosity Plugin Example'),
      ),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            ElevatedButton(
                onPressed: () => push(SharePage()), child: const Text('分享')),
            ElevatedButton(
                onPressed: () => push(GetInfoPage()),
                child: const Text('获取信息')),
            ElevatedButton(
                onPressed: () => push(JumpSettingPage()),
                child: const Text('跳转设置')),
            ElevatedButton(
                onPressed: () => push(CameraGalleryPage()),
                child: const Text('相机和图库')),
          ])),
    );
  }
}

void push(Widget widget) {
  showCupertinoModalPopup<dynamic>(
      context: navigatorKey.currentContext!, builder: (_) => widget);
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
