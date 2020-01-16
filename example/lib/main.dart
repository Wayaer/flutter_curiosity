import 'package:flutter/material.dart';
import 'package:flutter_curiosity/appinfo/AppInfo.dart';

void main() async {
  await AppInfo.getPackageInfo();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: App(),
  ));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Flutter Curiosity Plugin example app'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(),
          RaisedButton(onPressed: () {}, child: Text('按钮'))
        ],
      ),
    );
  }
}
