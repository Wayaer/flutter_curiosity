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
        appBar: AppBar(title: const Text('Share')),
        body: Universal(isScroll: true, children: <Widget>[
          ElevatedButton(
              onPressed: () => systemGallery(), child: const Text('打开系统相册')),
          ElevatedButton(
              onPressed: () => shareText(), child: const Text('分享文字')),
          ElevatedButton(
              onPressed: () => shareImage(), child: const Text('分享图片')),
          ElevatedButton(
              onPressed: () => shareImages(), child: const Text('分享多张图片')),
          const SizedBox(height: 20),
          Column(
              mainAxisSize: MainAxisSize.min,
              children: list.map((String value) => Text(value)).toList()),
        ]));
  }

  Future<void> systemGallery() async {
    final String? data = await openSystemGallery;
    list.add(data.toString());
    setState(() {});
  }

  void shareText() {
    systemShare(title: '分享图片', content: '分享几个文字', shareType: ShareType.text);
  }

  void shareImage() {
    if (list.isEmpty) {
      showToast('请先选择图片');
      return;
    }
    systemShare(title: '分享图片', content: list[0], shareType: ShareType.image);
  }

  void shareImages() {
    if (list.isEmpty) {
      showToast('请先选择图片');
      return;
    }
    final List<String> listPath = <String>[];
    listPath.addAll(list);
    systemShare(
        title: '分享图片', imagesPath: listPath, shareType: ShareType.images);
  }
}
