import 'package:curiosity/main.dart';
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
        appBar: AppBarText('Desktop'),
        body: Universal(
            padding: const EdgeInsets.all(10),
            isScroll: true,
            children: <Widget>[
              Container(
                  height: 40,
                  margin: const EdgeInsets.only(bottom: 10),
                  alignment: Alignment.center,
                  color: Colors.grey.withOpacity(0.3),
                  child: BasisText(text, color: Colors.black)),
              ElevatedText(
                  onPressed: () async {
                    final Size? size = await getDesktopWindowSize();
                    text = size.toString();
                    setState(() {});
                  },
                  text: 'getDesktopWindowSize'),
              ElevatedText(
                  onPressed: () => setDesktopWindowSize(const Size(600, 600)),
                  text: 'setDesktopWindowSize(600,600)'),
              ElevatedText(
                  onPressed: () =>
                      setDesktopMinWindowSize(const Size(300, 300)),
                  text: 'setDesktopMinWindowSize(300,300)'),
              ElevatedText(
                  onPressed: () =>
                      setDesktopMaxWindowSize(const Size(900, 900)),
                  text: 'setDesktopMaxWindowSize(900,900)'),
              ElevatedText(
                  onPressed: () => resetDesktopMaxWindowSize(),
                  text: 'resetDesktopMaxWindowSize'),
              ElevatedText(
                  onPressed: () => toggleDesktopFullScreen(),
                  text: 'toggleDesktopFullScreen'),
              ElevatedText(
                  onPressed: () => setDesktopFullScreen(true),
                  text: 'setDesktopFullScreen true'),
              ElevatedText(
                  onPressed: () => setDesktopFullScreen(false),
                  text: 'setDesktopFullScreen false'),
              ElevatedText(
                  onPressed: () async {
                    final bool? full = await getDesktopFullScreen();
                    text = full.toString();
                    setState(() {});
                  },
                  text: 'getDesktopFullScreen'),
              ElevatedText(
                  onPressed: () async {
                    final bool? hasBorders = await hasDesktopBorders;
                    text = hasBorders.toString();
                    setState(() {});
                  },
                  text: 'hasDesktopBorders'),
              const ElevatedText(
                  onPressed: toggleDesktopBorders,
                  text: 'toggleDesktopBorders'),
              ElevatedText(
                  onPressed: () => setDesktopBorders(true),
                  text: 'setDesktopBorders'),
              const ElevatedText(
                  onPressed: stayOnTopWithDesktop,
                  text: 'stayOnTopWithDesktop'),
              const ElevatedText(onPressed: focusDesktop, text: 'focusDesktop'),
              const SizedBox(height: 10),
              ElevatedText(
                  onPressed: () => setDesktopSizeTo4P7(),
                  text: 'setDesktopSizeTo4P7'),
              ElevatedText(
                  onPressed: () => setDesktopSizeTo5P5(),
                  text: 'setDesktopSizeTo5P5'),
              ElevatedText(
                  onPressed: () => setDesktopSizeTo5P8(),
                  text: 'setDesktopSizeTo5P8'),
              ElevatedText(
                  onPressed: () => setDesktopSizeTo6P1(),
                  text: 'setDesktopSizeTo6P1'),
            ]));
  }
}
