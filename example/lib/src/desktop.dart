import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';

class DesktopPage extends StatefulWidget {
  @override
  _DesktopPageState createState() => _DesktopPageState();
}

class _DesktopPageState extends State<DesktopPage> {
  String text = '';

  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
        appBar: AppBar(title: const Text('App and Device')),
        body: Universal(
            padding: const EdgeInsets.all(10),
            isScroll: true,
            children: <Widget>[
              Container(
                  height: 40,
                  margin:EdgeInsets.only(bottom:10),
                  alignment: Alignment.center,
                  color: Colors.grey.withOpacity(0.3),
                  child: BasisText(text, color: Colors.black)),
              ElevatedButton(
                  onPressed: () async {
                    final Size size = await getDesktopWindowSize();
                    text = size.toString();
                    setState(() {});
                  },
                  child: const Text('getDesktopWindowSize')),
              ElevatedButton(
                  onPressed: () => setDesktopWindowSize(const Size(600, 600)),
                  child: const Text('setDesktopWindowSize(600,600)')),
              ElevatedButton(
                  onPressed: () =>
                      setDesktopMinWindowSize(const Size(300, 300)),
                  child: const Text('setDesktopMinWindowSize(300,300)')),
              ElevatedButton(
                  onPressed: () =>
                      setDesktopMaxWindowSize(const Size(900, 900)),
                  child: const Text('setDesktopMaxWindowSize(900,900)')),
              ElevatedButton(
                  onPressed: () => resetDesktopMaxWindowSize(),
                  child: const Text('resetDesktopMaxWindowSize')),
              ElevatedButton(
                  onPressed: () => toggleDesktopFullScreen(),
                  child: const Text('toggleDesktopFullScreen')),
              ElevatedButton(
                  onPressed: () => setDesktopFullScreen(true),
                  child: const Text('setDesktopFullScreen true')),
              ElevatedButton(
                  onPressed: () => setDesktopFullScreen(false),
                  child: const Text('setDesktopFullScreen false')),
              ElevatedButton(
                  onPressed: () async {
                    final bool full = await getDesktopFullScreen();
                    text = full.toString();
                    setState(() {});
                  },
                  child: const Text('getDesktopFullScreen')),
            ]));
  }
}
