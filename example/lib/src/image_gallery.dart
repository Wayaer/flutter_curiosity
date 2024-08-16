import 'dart:io';

import 'package:curiosity/main.dart';
import 'package:fl_extended/fl_extended.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'dart:ui' as ui;

import 'package:path_provider/path_provider.dart';

class ImageGalleryPage extends StatefulWidget {
  const ImageGalleryPage({super.key});

  @override
  State<ImageGalleryPage> createState() => _ImageGalleryPageState();
}

class _ImageGalleryPageState extends State<ImageGalleryPage> {
  GlobalKey imgKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('ImageGalleryTools'),
        body: Universal(padding: const EdgeInsets.all(20), children: [
          RepaintBoundary(
              key: imgKey,
              child: Container(
                  width: double.infinity,
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.deepOrangeAccent),
                  child: const Text('ImageGalleryTools',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)))),
          20.heightBox,
          ElevatedText(text: 'saveBytesImage', onPressed: saveBytesImage),
          20.heightBox,
          ElevatedText(text: 'saveFilePath', onPressed: saveFilePath),
        ]));
  }

  void saveBytesImage() async {
    final byteData = await imgKey.screenshots(
        format: ui.ImageByteFormat.png,
        pixelRatio: context.mediaQuery.devicePixelRatio);
    if (byteData == null) {
      showToast('保存失败');
      return;
    }
    final result = await ImageGalleryTools.saveBytesImage(
        byteData.buffer.asUint8List(),
        extension: ImageGalleryExtension.png);
    showToast(result ? '保存成功' : '保存失败');
  }

  void saveFilePath() async {
    final byteData = await imgKey.screenshots(
        format: ui.ImageByteFormat.png,
        pixelRatio: context.mediaQuery.devicePixelRatio);
    if (byteData == null) {
      showToast('保存失败');
      return;
    }
    final path = await writeAsBytes(byteData.buffer.asUint8List());
    if (path == null) return;
    final result = await ImageGalleryTools.saveFilePath(path);
    showToast(result ? '保存成功' : '保存失败');
  }

  Future<String?> writeAsBytes(List<int> bytes) async {
    final cacheDir = await getApplicationCacheDirectory();
    String path = '${cacheDir.path}/';
    String name = '${DateTime.now().millisecondsSinceEpoch}.png';
    Directory dir = Directory(path);
    if (!dir.existsSync()) {
      dir = await dir.create(recursive: true);
      if (!dir.existsSync()) {
        '路径创建失败'.log();
        return null;
      }
    }
    path += name;
    final File file = File(path);
    await file.writeAsBytes(bytes);
    await file.create();
    if (File(path).existsSync()) {
      log('文件保存成功=> $path');
      await showToast('文件保存成功=> $path');
      return path;
    }
    return null;
  }
}
