import 'dart:ui';

import 'package:curiosity/src/camera/camera_gallery.dart';
import 'package:curiosity/src/desktop.dart';
import 'package:curiosity/src/get_info.dart';
import 'package:curiosity/src/keyboard.dart';
import 'package:curiosity/src/share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //// 关闭辅助触控
  window.onSemanticsEnabledChanged = () {};
  RendererBinding.instance.setSemanticsEnabled(false);

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

  runApp(GlobalWidgetsApp(
      debugShowCheckedModeBanner: false, title: 'Curiosity', home: App()));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Flutter Curiosity Plugin Example')),
      body: Universal(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () => push(SharePage()), child: const Text('分享')),
            ElevatedButton(
                onPressed: () => push(KeyboardPage()),
                child: const Text('键盘状态')),
            ElevatedButton(
                onPressed: () => push(GetInfoPage()),
                child: const Text('获取信息')),
            ElevatedButton(
                onPressed: () => push(JumpSettingPage()),
                child: const Text('跳转设置')),
            ElevatedButton(
                onPressed: () => push(CameraGalleryPage()),
                child: const Text('相机和图库')),
            if (isDesktop)
              ElevatedButton(
                  onPressed: () => push(DesktopPage()),
                  child: const Text('Desktop窗口控制')),
          ]),
    );
  }
}

class JumpSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    children.add(ElevatedButton(
        onPressed: () => jumpAppSetting, child: const Text('跳转APP设置')));
    children.addAll(SettingType.values
        .map((SettingType value) =>
        ElevatedButton(
            onPressed: () => jumpSystemSetting(settingType: value),
            child: Text(value.toString())))
        .toList());
    return OverlayScaffold(
        appBar: AppBar(title: const Text('Android Jump Setting')),
        body: Universal(isScroll: true, children: children));
  }
}

Widget showText(dynamic key, dynamic value) {
  return Visibility(
      visible: value != null &&
          value
              .toString()
              .isNotEmpty &&
          value.toString() != 'null',
      child: Container(
          margin: const EdgeInsets.all(10),
          child: Text(key.toString() + ' = ' + value.toString())));
}

Future<bool> requestPermissions(Permission permission, String text) async {
  final PermissionStatus status = await permission.status;
  if (status != PermissionStatus.granted) {
    final Map<Permission, PermissionStatus> statuses =
    await <Permission>[permission].request();
    if (!(statuses[permission] == PermissionStatus.granted)) {
      openAppSettings();
    }
    return statuses[permission] == PermissionStatus.granted;
  }
  return true;
}
