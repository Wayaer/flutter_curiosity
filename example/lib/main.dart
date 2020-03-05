import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_curiosity/curiosity.dart';

import 'ScanPage.dart';

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: App(),
  ));
}

class App extends StatelessWidget {
  bool san = true;

  @override
  Widget build(BuildContext context) {
    return san ? ScanPage() : Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Flutter Curiosity Plugin app'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(),
          RaisedButton(
              onPressed: () {
                select();
              },
              child: Text('按钮'))
        ],
      ),
    );
  }

  select() async {
    List<AssetMedia> data = await PicturePicker.openSelect();
    AssetMedia assetMedia = data[0];
    log(assetMedia.path);
    final result = await ScanUtils.scanImagePath(assetMedia.path);
    log(result.code);
  }

}
