import 'package:curiosity/src/camera_gallery.dart';
import 'package:curiosity/src/desktop.dart';
import 'package:curiosity/src/get_info.dart';
import 'package:curiosity/src/keyboard.dart';
import 'package:curiosity/src/open_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('isWeb = $isWeb');
  debugPrint('isMacOS = $isMacOS');
  debugPrint('isAndroid = $isAndroid');
  debugPrint('isIOS = $isIOS');
  debugPrint('isMobile = $isMobile');
  debugPrint('isDesktop = $isDesktop');
  runApp(MaterialApp(
      navigatorKey: GlobalOptions().navigatorKey,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      title: 'Curiosity',
      home: const App()));
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    if (isMobile) {
      Curiosity().native.onResultListener(
          activityResult: (AndroidActivityResult result) {
        log('AndroidResult requestCode = ${result.requestCode}  '
            'resultCode = ${result.resultCode}  data = ${result.data}');
      }, requestPermissionsResult: (AndroidRequestPermissionsResult result) {
        log('AndroidRequestPermissionsResult: requestCode = ${result.requestCode}  \n'
            ' permissions = ${result.permissions} \n grantResults = ${result.grantResults}');
      });
    }
    if (!isWeb && isDesktop) {
      /// 设置桌面版为 指定 尺寸
      addPostFrameCallback((Duration duration) async {
        await Curiosity().desktop.focusDesktop();
        var value = await Curiosity().desktop.setDesktopSizeTo4P7();
        log('限制桌面宽高：$value');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('Flutter Curiosity Plugin Example'),
        body: Universal(
            mainAxisAlignment: MainAxisAlignment.center,
            expand: true,
            children: [
              if (isMobile || isMacOS) ...[
                ElevatedText(
                    onPressed: () => push(const GetInfoPage()), text: '获取信息'),
                ElevatedText(
                    onPressed: () => push(const OpenSettingPage()),
                    text: '跳转设置'),
              ],
              if (isMobile) ...[
                ElevatedText(
                    onPressed: () => push(const CameraGalleryPage()),
                    text: '相机、图库'),
                ElevatedText(
                    onPressed: () => push(const KeyboardPage()), text: '键盘状态'),
              ],
              if (isDesktop)
                ElevatedText(
                    onPressed: () => push(const DesktopPage()),
                    text: 'Desktop窗口控制'),
            ]));
  }
}

class ShowText extends StatelessWidget {
  const ShowText(this.keyName, this.value, {Key? key}) : super(key: key);
  final dynamic keyName;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: value != null &&
            value.toString().isNotEmpty &&
            value.toString() != 'null',
        child: Container(
            margin: const EdgeInsets.all(10),
            child: Text('$keyName = $value')));
  }
}

Future<bool> getPermission(Permission permission) async {
  PermissionStatus status = await permission.status;
  if (!status.isGranted) {
    status = await permission.request();
    if (!status.isGranted) {
      openAppSettings();
    }
  }
  return status.isGranted;
}

class ElevatedText extends StatelessWidget {
  const ElevatedText({Key? key, required this.text, required this.onPressed})
      : super(key: key);

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      ElevatedButton(onPressed: onPressed, child: BText(text));
}

class AppBarText extends AppBar {
  AppBarText(String text, {Key? key})
      : super(
            key: key,
            elevation: 0,
            title: BText(text, fontSize: 18, fontWeight: FontWeight.bold),
            centerTitle: true);
}
