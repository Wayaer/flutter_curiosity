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
                  margin: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  color: Colors.grey.withOpacity(0.3),
                  child: BasisText(text, color: Colors.black, height: 1.5)),
              Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  children: const <Widget>[
                    ElevatedText(
                        onPressed: setDesktopSizeTo4P7,
                        text: 'setDesktopSizeTo4P7'),
                    ElevatedText(
                        onPressed: setDesktopSizeTo5P5,
                        text: 'setDesktopSizeTo5P5'),
                    ElevatedText(
                        onPressed: setDesktopSizeTo5P8,
                        text: 'setDesktopSizeTo5P8'),
                    ElevatedText(
                        onPressed: setDesktopSizeTo6P1,
                        text: 'setDesktopSizeTo6P1'),
                    ElevatedText(
                        onPressed: setDesktopSizeToIPad11,
                        text: 'setDesktopSizeToIPad11'),
                    ElevatedText(
                        onPressed: setDesktopSizeToIPad10P5,
                        text: 'setDesktopSizeToIPad10P5'),
                    ElevatedText(
                        onPressed: setDesktopSizeToIPad9P7,
                        text: 'setDesktopSizeToIPad9P7'),
                  ]),
              const SizedBox(height: 20),
              ElevatedText(
                  onPressed: () async {
                    final Size? size = await getDesktopWindowSize();
                    text = size.toString();
                    setState(() {});
                  },
                  text: 'getDesktopWindowSize'),
              ElevatedText(
                  onPressed: () =>
                      changeState(setDesktopWindowSize(const Size(600, 600))),
                  text: 'setDesktopWindowSize(600,600)'),
              ElevatedText(
                  onPressed: () => changeState(
                      setDesktopMinWindowSize(const Size(300, 300))),
                  text: 'setDesktopMinWindowSize(300,300)'),
              ElevatedText(
                  onPressed: () => changeState(
                      setDesktopMaxWindowSize(const Size(900, 900))),
                  text: 'setDesktopMaxWindowSize(900,900)'),
              ElevatedText(
                  onPressed: () => changeState(resetDesktopMaxWindowSize()),
                  text: 'resetDesktopMaxWindowSize'),
              ElevatedText(
                  onPressed: () => changeState(toggleDesktopFullScreen()),
                  text: 'toggleDesktopFullScreen'),
              ElevatedText(
                  onPressed: () => changeState(setDesktopFullScreen(true)),
                  text: 'setDesktopFullScreen true'),
              ElevatedText(
                  onPressed: () => changeState(setDesktopFullScreen(false)),
                  text: 'setDesktopFullScreen false'),
              ElevatedText(
                  onPressed: () => changeState(getDesktopFullScreen()),
                  text: 'getDesktopFullScreen'),
              ElevatedText(
                  onPressed: () => changeState(hasDesktopBorders),
                  text: 'hasDesktopBorders'),
              ElevatedText(
                  onPressed: () => changeState(toggleDesktopBorders()),
                  text: 'toggleDesktopBorders'),
              ElevatedText(
                  onPressed: () => changeState(setDesktopBorders(true)),
                  text: 'setDesktopBorders'),
              ElevatedText(
                  onPressed: () => changeState(stayOnTopWithDesktop()),
                  text: 'stayOnTopWithDesktop'),
              ElevatedText(
                  onPressed: () => changeState(stayOnTopWithDesktop(false)),
                  text: 'stayOnTopWithDesktop (false)'),
              const ElevatedText(onPressed: focusDesktop, text: 'focusDesktop'),
            ]));
  }

  void changeState(Future<dynamic> state) {
    state.then((dynamic value) {
      text = 'hashCode(${state.hashCode}): ' + value.toString();
      setState(() {});
    });
  }
}
