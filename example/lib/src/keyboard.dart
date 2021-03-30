import 'package:flutter/material.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';

class KeyboardPage extends StatefulWidget {
  @override
  _KeyboardState createState() => _KeyboardState();
}

class _KeyboardState extends State<KeyboardPage> {
  @override
  void initState() {
    super.initState();
    keyboardListener((bool visibility) {
      log(visibility);
      showToast(visibility ? '键盘已弹出' : '键盘已关闭');
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
        appBar: AppBar(title: const Text('Share')),
        body: const Universal(
            mainAxisAlignment: MainAxisAlignment.center,
            padding: EdgeInsets.all(20),
            children: <Widget>[
              TextField(),
            ]));
  }
}
