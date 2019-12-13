import 'package:flutter/material.dart';
import 'package:flutter_curiosity/curiosity.dart';

void main() {
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
          RaisedButton(
              onPressed: () {
                getVersion(context);
              },
              child: Text('按钮'))
        ],
      ),
    );
  }

  getVersion(context) async {
    var version = await FlutterCuriosity.platformVersion;
    debugPrint(version);
  }
}
