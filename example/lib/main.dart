import 'package:flutter/material.dart';
import 'package:flutter_curiosity/appinfo/AppInfo.dart';
import 'package:flutter_curiosity_example/ScanPage.dart';

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: App(),
  ));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScanPage();
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
                getPackageInfo();
              },
              child: Text('按钮'))
        ],
      ),
    );
  }

  getPackageInfo() async {
    String rootDirectory = await AppInfo.getRootDirectory();
    List<String> data = await AppInfo.getDirectoryAllName(rootDirectory, isAbsolutePath: true);
    data.map((v) {
      print(v);
    }).toList();
  }
}
