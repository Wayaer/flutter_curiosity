import 'package:curiosity/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';

class KeyboardPage extends StatefulWidget {
  const KeyboardPage({Key? key}) : super(key: key);

  @override
  State<KeyboardPage> createState() => _KeyboardState();
}

class _KeyboardState extends State<KeyboardPage> {
  @override
  void initState() {
    super.initState();
    Curiosity().native.keyboardListener((bool visibility) {
      showToast(visibility ? '键盘已弹出' : '键盘已关闭');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('Keyboard'),
        body: const Universal(
            mainAxisAlignment: MainAxisAlignment.center,
            padding: EdgeInsets.all(20),
            children: <Widget>[
              TextField(),
            ]));
  }
}
