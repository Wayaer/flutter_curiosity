import 'package:curiosity/src/get_info.dart';
import 'package:curiosity/src/image_gallery.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_extended/fl_extended.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  log('isWeb = ${Curiosity.isWeb}\n'
      'isMacOS = ${Curiosity.isMacOS}\n'
      'isAndroid = ${Curiosity.isAndroid}\n'
      'isHarmonyOS = ${Curiosity.isHarmonyOS}\n'
      'isIOS = ${Curiosity.isIOS}\n'
      'isMobile = ${Curiosity.isMobile}\n'
      'isDesktop = ${Curiosity.isDesktop}');
  runApp(MaterialApp(
      navigatorKey: FlExtended().navigatorKey,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      title: 'Curiosity',
      home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBarText('Curiosity Plugin Example'),
          body: const App())));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends NativeKeyboardStatusState<App>
    with WidgetsBindingObserver {
  ValueNotifier<NativeKeyboardStatus?> keyboardStatusNotifier =
      ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    addObserver(this);
    if (Curiosity.isMobile) {
      Curiosity.native.activityResult.add(onAndroidActivityResult);
    }
  }

  void onAndroidActivityResult(AndroidActivityResult result) {
    'AndroidResult requestCode = ${result.requestCode}  '
            'resultCode = ${result.resultCode}  data = ${result.data}'
        .log();
  }

  @override
  void onKeyboardListener(NativeKeyboardStatus params) {
    keyboardStatusNotifier.value = params;
  }

  @override
  Widget build(BuildContext context) {
    return Universal(expand: true, children: [
      if (Curiosity.isMobile || Curiosity.isMacOS)
        ElevatedText(onPressed: () => push(const GetInfoPage()), text: '获取信息'),
      if (Curiosity.isAndroid)
        ElevatedText(onPressed: installApk, text: '安装apk'),
      ElevatedText(onPressed: Curiosity.native.exitApp, text: '退出 App'),
      if (Curiosity.isMobile) ...[
        ElevatedText(
            onPressed: () {
              push(const ImageGalleryPage());
            },
            text: 'ImageGalleryTools'),
        Universal(padding: EdgeInsets.all(20), children: [
          ValueListenableBuilder(
              valueListenable: keyboardStatusNotifier,
              builder: (_, value, __) {
                return Text(
                    'keyboardHeight:${value?.keyboardHeight}\nvisibility:${value?.visibility}',
                    textAlign: TextAlign.center);
              }),
          TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(hintText: '监听键盘状态'))
        ]),
      ],
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
      final result = await Curiosity.native.installApk(path!);
      "installApk======$result".log();
    }
  }

  @override
  void dispose() {
    super.dispose();
    Curiosity.native.activityResult.remove(onAndroidActivityResult);
  }
}

class TextBox extends StatelessWidget {
  const TextBox(this.keyName, this.value, {super.key});

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
  const ElevatedText({super.key, required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      ElevatedButton(onPressed: onPressed, child: Text(text));
}

class AppBarText extends AppBar {
  AppBarText(String text, {super.key})
      : super(
            elevation: 0,
            title: Text(text,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            centerTitle: true);
}
