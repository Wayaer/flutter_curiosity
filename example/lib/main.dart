import 'package:flutter/material.dart';
import './ScanPage.dart';

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
              },
              child: Text('按钮'))
        ],
      ),
    );
  }

}
