import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/curiosity.dart';

import 'ScanPage.dart';

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Curiosity',
    home: App(),
  ));
}

class App extends StatelessWidget {
  bool san = true;
  StateSetter setState;
  List<AssetMedia> list = List();

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
          StatefulBuilder(builder: (BuildContext context, StateSetter state) {
            setState = state;
            return Column(children: showText());
          },),
          RaisedButton(
              onPressed: () {
                scan(context);
              },
              child: Text('扫码')),
          RaisedButton(
              onPressed: () {
                select();
              },
              child: Text('图片选择')),
          RaisedButton(
              onPressed: () {
                getGPS();
              },
              child: Text('获取gps状态')),
          RaisedButton(
              onPressed: () {
                GPSTools.jumpSetting();
              },
              child: Text('跳转GPS设置')),

        ],
      ),
    );
  }

  getGPS() async {
    var data = await GPSTools.getStatus();
//    log(data);
  }

  List<Widget> showText() {
    List<Widget> widget = List();
    list.map((value) {
      widget.add(Text(value.path + '==' + value.fileName));
    }).toList();
    return widget;
  }

  scan(BuildContext context) {
    showCupertinoModalPopup(context: context, builder: (context) => ScanPage());
  }

  select() async {
    PicturePickerOptions options = PicturePickerOptions();
    options.selectionMode = 1;
    options.pickerSelectType = 2;
    list = await PicturePicker.openPicker(options);
    setState(() {});
  }

}
