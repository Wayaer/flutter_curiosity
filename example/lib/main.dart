import 'package:curiosity/src/desktop.dart';
import 'package:curiosity/src/get_info.dart';
import 'package:file_picker/file_picker.dart';
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
      navigatorKey: GlobalWayUI().navigatorKey,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      title: 'Curiosity',
      home: Scaffold(
          appBar: AppBarText('Flutter Curiosity Plugin Example'),
          body: const App())));
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
      Curiosity().native.activityResult.add(onAndroidActivityResult);
      Curiosity().native.keyboardStatus.add(keyboardStatus);
    }
    if (!isWeb && isDesktop) {
      /// 设置桌面版为 指定 尺寸
      addPostFrameCallback((Duration duration) async {
        await Curiosity().desktop.focus();
        var value = await Curiosity().desktop.setSizeTo4P7();
        log('限制桌面宽高：$value');
      });
    }
  }

  void onAndroidActivityResult(AndroidActivityResult result) {
    log('AndroidResult requestCode = ${result.requestCode}  '
        'resultCode = ${result.resultCode}  data = ${result.data}');
  }

  void keyboardStatus(bool visibility) {
    showToast(visibility ? '键盘已弹出' : '键盘已关闭');
  }

  @override
  Widget build(BuildContext context) {
    return Universal(
        mainAxisAlignment: MainAxisAlignment.center,
        expand: true,
        children: [
          if (isMobile || isMacOS)
            ElevatedText(
                onPressed: () => push(const GetInfoPage()), text: '获取信息'),
          if (isAndroid) ElevatedText(onPressed: installApk, text: '安装apk'),
          if (isMobile)
            const SizedBox(
                width: 200,
                child: TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(hintText: '监听键盘状态'))),
          if (isDesktop)
            ElevatedText(
                onPressed: () => push(const DesktopPage()),
                text: 'Desktop窗口控制'),
        ]);
  }

  void installApk() async {
    var status = await getPermission(Permission.requestInstallPackages);
    if (!status) return;
    final res = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['apk']);
    if (res?.files.isNotEmpty ?? false) {
      final path = res!.files.single.path;
      if (path.isEmptyOrNull) return;
      final result = await Curiosity().native.installApk(path!);
      log("installApk======$result");
    }
  }

  @override
  void dispose() {
    super.dispose();
    Curiosity().native.activityResult.remove(onAndroidActivityResult);
    Curiosity().native.keyboardStatus.remove(keyboardStatus);
  }
}

class TextBox extends StatelessWidget {
  const TextBox(this.keyName, this.value, {Key? key}) : super(key: key);
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
