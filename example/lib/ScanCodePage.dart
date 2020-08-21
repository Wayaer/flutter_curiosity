import 'package:curiosity/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanCodePage extends StatefulWidget {
  @override
  ScanCodePageState createState() => ScanCodePageState();
}

class ScanCodePageState extends State<ScanCodePage> {
  ScannerController controller =
  ScannerController(resolutionPreset: ResolutionPreset.High);
  bool showScanner = false;

  @override
  void initState() {
    super.initState();
    initController();
    Tools.addPostFrameCallback((duration) {
      Tools.timerTools(Duration(milliseconds: 200), () {
        showScanner = true;
        setState(() {});
      });
    });
  }

  bool isFirst = true;
  bool flash = false;

  Future<void> initController() async {
    controller.addListener(() {
      var code = controller.code;
      if (code != null) {
        if (isFirst && code != null && code.length > 0) {
          print(code);
          showToast(code);
        }
      }
    });
    controller.setFlashMode(false);
  }

  double widthRatio = 0.95;

  @override
  Widget build(BuildContext context) {
    double boxWidth = ScreenFit.getWidth(0) * 0.55;
    double scannerWidth = ScreenFit.getWidth(0) * widthRatio;
    return Scaffold(
      body: Universal(
        isStack: true,
        children: <Widget>[
          ScannerBox(
              borderColor: Color(0xFF51BEF7),
              scannerColor: Color(0xFF51BEF7),
              size: Size(boxWidth, boxWidth),
              child: Universal(
                visible: showScanner,
                child: Scanner(
                  leftRatio: (1 - widthRatio) / 2,
                  widthRatio: widthRatio,
                  topRatio: (1 - (scannerWidth / ScreenFit.getHeight(0))) / 2,
                  heightRatio: scannerWidth / ScreenFit.getHeight(0),
                  controller: controller,
                ),
              )),
          Align(
            alignment: Alignment.bottomCenter,
            child: IconBox(
              size: 30,
              color: flash ? Colors.cyan : Colors.white,
              icon: Icons.highlight,
              margin: EdgeInsets.only(bottom: ScreenFit.getHeight(40)),
              title: Text(
                '轻触照亮',
                style: TextStyle(
                  color: flash ? Colors.cyan : Colors.white,
                ),
              ),
              direction: Axis.vertical,
              onTap: () => openFlash(),
            ),
          )
        ],
      ),
    );
  }

  openFlash() async {
    if (controller == null) return;
    controller.setFlashMode(!flash);
    flash = !flash;
    setState(() {});
  }
}

class ScanCodeShowPage extends StatelessWidget {
  final String text;

  const ScanCodeShowPage({Key key, @required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SimpleButton(
          onTap: () {
            Tools.copy(text);
            showToast('复制成功');
          },
          text: text,
          maxLines: 100,
          textStyle: TextStyle(color: Colors.white, fontSize: 15),
        ));
  }
}

class ScanUtils {
  static openScan(BuildContext context) async {
    var permission = await Utils.requestPermissions(Permission.camera, '相机',
        showAlert: false) &&
        await Utils.requestPermissions(Permission.storage, '手机存储',
            showAlert: false);
    if (permission) {
      return await showCupertinoModalPopup(
          context: context, builder: (BuildContext context) => ScanCodePage());
    }
  }

  static openScanCodeShow(BuildContext context, String text) async {
    await showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) =>
            ScanCodeShowPage(
              text: text,
            ));
  }
}
