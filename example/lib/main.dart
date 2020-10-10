import 'package:curiosity/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(GlobalMaterial(debugShowCheckedModeBanner: false, title: 'Curiosity', home: App()));
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool san = true;
  StateSetter textSetState;
  List<AssetMedia> list = <AssetMedia>[];

  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Flutter Curiosity Plugin app'),
      ),
      body: Universal(
        isScroll: true,
        children: <Widget>[
          const Center(),
          StatefulBuilder(
            builder: (BuildContext context, StateSetter state) {
              textSetState = state;
              return Column(mainAxisSize: MainAxisSize.min, children: showText());
            },
          ),
          RaisedButton(onPressed: () => getAppInfo(), child: const Text('获取appInfo')),
          RaisedButton(onPressed: () => scan(context), child: const Text('扫码')),
          RaisedButton(onPressed: () => select(), child: const Text('图片选择')),
          RaisedButton(onPressed: () => deleteCacheDirFile(), child: const Text('清除图片选择缓存')),
          RaisedButton(onPressed: () => shareText(), child: const Text('分享文字')),
          RaisedButton(onPressed: () => shareImage(), child: const Text('分享图片')),
          RaisedButton(onPressed: () => shareImages(), child: const Text('分享多张图片')),
          RaisedButton(onPressed: () => openSystemGallery(), child: const Text('打开系统相册')),
          RaisedButton(onPressed: () => openSystemCamera(), child: const Text('打开系统相机')),
          RaisedButton(onPressed: () => getGPS(), child: const Text('获取gps状态')),
          RaisedButton(onPressed: () => NativeTools.jumpAppSetting(), child: const Text('跳转APP设置')),
        ],
      ),
    );
  }

  Future<void> getAppInfo() async {
    final AppInfoModel data = await AppInfo.getPackageInfo();
    log(data.packageName);
  }

  Future<void> openSystemGallery() async {
    final String data = await GalleryTools.openSystemGallery();
    showToast(data.toString());
  }

  Future<void> openSystemCamera() async {
    final String data = await GalleryTools.openSystemCamera();
    showToast(data.toString());
  }

  void shareText() {
    NativeTools.systemShare(title: '分享图片', content: '分享几个文字', shareType: ShareType.text);
  }

  void shareImage() {
    if (list.isEmpty) {
      showToast('请先选择图片');
      return;
    }
    NativeTools.systemShare(title: '分享图片', content: list[0].path, shareType: ShareType.image);
  }

  void shareImages() {
    if (list.isEmpty) {
      showToast('请先选择图片');
      return;
    }
    final List<String> listPath = <String>[];
    listPath.add(list[0].path);
    listPath.add(list[0].path);
    NativeTools.systemShare(title: '分享图片', imagesPath: listPath, shareType: ShareType.images);
  }

  Future<void> getGPS() async {
    final bool data = await NativeTools.getGPSStatus();
    showToast(data.toString());
  }

  Future<void> scan(BuildContext context) async {
    final bool permission = await Utils.requestPermissions(Permission.camera, '相机', showAlert: false) &&
        await Utils.requestPermissions(Permission.storage, '手机存储', showAlert: false);
    if (permission) {
      showCupertinoModalPopup<dynamic>(
          context: context,
          builder: (_) => ScannerPage(
                scanResult: (String text) {
                  log(text);
                  showToast(text);
                },
              ));
    } else {
      openAppSettings();
    }
  }

  Future<void> select() async {
    final PicturePickerOptions options = PicturePickerOptions();
    options.pickerSelectType = 1;
    options.enableCrop = true;
    options.scaleEnabled = true;
    options.isGif = true;
    options.isCamera = true;
    options.hideBottomControls = true;
    options.showCropFrame = true;
    options.freeStyleCropEnabled = true;
    options.originalPhoto = true;
    options.maxSelectNum = 4;
    list = await GalleryTools.openImagePicker(options);
    setState(() {});
  }

  Future<dynamic> deleteCacheDirFile() async {
    final String data = await GalleryTools.deleteCacheDirFile();
    showToast(data);
  }

  List<Widget> showText() {
    final List<Widget> widget = <Widget>[];
    list.map((AssetMedia value) {
      widget.add(Text(value.path + '==' + value.fileName));
    }).toList();
    return widget;
  }
}
