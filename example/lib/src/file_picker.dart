import 'dart:io';

import 'package:curiosity/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';

class FilePickerPage extends StatefulWidget {
  @override
  _FilePickerPageState createState() => _FilePickerPageState();
}

class _FilePickerPageState extends State<FilePickerPage> {
  bool san = true;
  List<String> paths = <String>[];
  bool needShow = false;

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        appBar: AppBarText('File Picker'),
        body: Universal(isScroll: true, children: <Widget>[
          const SizedBox(height: 12),
          ElevatedText(onPressed: filePicker, text: '文件选择器'),
          ElevatedText(onPressed: _saveFilePicker, text: '文件保存选择器'),
          const SizedBox(height: 20),
          Column(
              children: paths.builder((String path) => needShow
                  ? Column(children: <Widget>[
                      ShowText('path', path),
                      if (path.isNotEmpty)
                        Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(20),
                            child: Image.file(File(path)))
                    ])
                  : ShowText('path', path)))
        ]));
  }

  Future<void> _saveFilePicker() async {
    needShow = false;
    final String? data = await Curiosity.instance.desktop.saveFilePicker(
        optionsWithMacOS: SaveFilePickerOptionsWithMacOS(
            allowedFileTypes: <String>['png', 'jpe']));
    if (data != null) {
      paths = <String>[data];
      setState(() {});
    }
  }

  Future<void> filePicker() async {
    needShow = true;
    final List<String>? data = await Curiosity.instance.desktop.openFilePicker(
        optionsWithMacOS:
            FilePickerOptionsWithMacOS(allowedFileTypes: <String>['png']));
    if (data != null) {
      paths = data;
      setState(() {});
    }
  }
}
