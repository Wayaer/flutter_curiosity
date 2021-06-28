import 'dart:ui';

import 'package:curiosity/src/camera/camera_gallery.dart';
import 'package:curiosity/src/desktop.dart';
import 'package:curiosity/src/get_info.dart';
import 'package:curiosity/src/keyboard.dart';
import 'package:curiosity/src/open_app.dart';
import 'package:curiosity/src/share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  window.onSemanticsEnabledChanged = () {};
  RendererBinding.instance!.setSemanticsEnabled(false);

  print('isWeb = $isWeb');
  print('isMacOS = $isMacOS');
  print('isAndroid = $isAndroid');
  print('isIOS = $isIOS');
  print('isMobile = $isMobile');
  print('isDesktop = $isDesktop');
  runApp(GlobalWidgetsApp(
      debugShowCheckedModeBanner: false, title: 'Curiosity', home: App()));
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    if (isMobile) {
      log('添加 原生回调监听');
      onResultListener(activityResult: (AndroidActivityResult result) {
        log('AndroidResult requestCode = ${result.requestCode}  '
            'resultCode = ${result.resultCode}  data = ${result.data}');
      }, requestPermissionsResult: (AndroidRequestPermissionsResult result) {
        log('AndroidRequestPermissionsResult: requestCode = ${result.requestCode}  \n'
            ' permissions = ${result.permissions} \n grantResults = ${result.grantResults}');
      });
    }
    if (!isWeb && isDesktop) {
      /// 设置桌面版为 指定 尺寸
      addPostFrameCallback((Duration duration) {
        setDesktopSizeToIPad9P7(p: 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
      backgroundColor: Colors.white,
      appBar: AppBarText('Flutter Curiosity Plugin Example'),
      body: Universal(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isMobile)
              ElevatedText(onPressed: () => push(SharePage()), text: '分享'),
            if (isMobile)
              ElevatedText(onPressed: () => push(KeyboardPage()), text: '键盘状态'),
            ElevatedText(onPressed: () => push(GetInfoPage()), text: '获取信息'),
            if (isAndroid)
              ElevatedText(
                  onPressed: () => push(OpenSettingPage()), text: '跳转APP'),
            if (isMobile)
              ElevatedText(
                  onPressed: () => push(CameraGalleryPage()), text: '相机和图库'),
            if (isDesktop)
              ElevatedText(
                  onPressed: () => push(DesktopPage()), text: 'Desktop窗口控制'),
          ]),
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

class ElevatedText extends StatelessWidget {
  const ElevatedText({Key? key, required this.text, required this.onPressed})
      : super(key: key);

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Universal(
        onTap: onPressed,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(boxShadow: const <BoxShadow>[
          BoxShadow(
              color: color,
              offset: Offset(0, 0),
              blurRadius: 1.0,
              spreadRadius: 1.0)
        ], color: color, borderRadius: BorderRadius.circular(4)),
        child: BasisText(text, color: Colors.black),
      );
}

class AppBarText extends AppBar {
  AppBarText(String text, {Key? key})
      : super(
          key: key,
          elevation: 0,
          iconTheme: const IconThemeData.fallback(),
          title: BasisText(text,
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          centerTitle: true,
          backgroundColor: color,
        );
}

const Color color = Colors.amber;
