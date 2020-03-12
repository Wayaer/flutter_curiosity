import 'dart:developer';

import 'package:flutter/cupertino.dart';
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
    return Scaffold(
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
//                select();
                NativeUtils.callPhone('13282830824');
//                scan(context);
              },
              child: Text('按钮'))
        ],
      ),
    );
  }

  scan(BuildContext context) {
    showCupertinoModalPopup(context: context, builder: (context) => ScanPage());
  }

  select() async {
    PicturePickerOptions options = PicturePickerOptions();
    options.selectionMode = 1;
    List<AssetMedia> data = await PicturePicker.openPicker(options);
    log(data.toString());
  }

}
