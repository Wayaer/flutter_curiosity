import 'package:curiosity/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';

class SharePage extends StatefulWidget {
  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  List<String> list = <String>[];

  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
        appBar: const AppBarText('Share'),
        body: Universal(
            isScroll: true,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedText(onPressed: () => systemGallery(), text: '打开系统相册'),
              ElevatedText(onPressed: shareText, text: '分享文字'),
              ElevatedText(onPressed: () => shareImage(), text: '分享图片'),
              ElevatedText(onPressed: () => shareImages(), text: '分享多张图片'),
              const SizedBox(height: 20),
              Column(
                  mainAxisSize: MainAxisSize.min,
                  children: list.map((String value) => Text(value)).toList()),
            ]));
  }

  Future<void> systemGallery() async {
    final String? data = await openSystemGallery();
    list.add(data.toString());
    setState(() {});
  }

  void shareText() {
    openSystemShare(title: '分享图片', content: '分享几个文字', shareType: ShareType.text);
  }

  void shareImage() {
    if (list.isEmpty) {
      showToast('请先选择图片');
      return;
    }
    openSystemShare(title: '分享图片', content: list[0], shareType: ShareType.image);
  }

  void shareImages() {
    if (list.isEmpty) {
      showToast('请先选择图片');
      return;
    }
    final List<String> listPath = <String>[];
    listPath.addAll(list);
    openSystemShare(
        title: '分享图片', imagesPath: listPath, shareType: ShareType.images);
  }
}
