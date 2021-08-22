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
    return ExtendedScaffold(
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
                  child: BText(text, color: Colors.black, height: 1.5)),
              Wrap(alignment: WrapAlignment.center, spacing: 10, children: <
                  Widget>[
                ElevatedText(
                    onPressed: Curiosity.instance.desktop.setDesktopSizeTo4P7,
                    text: 'setDesktopSizeTo4P7'),
                ElevatedText(
                    onPressed: Curiosity.instance.desktop.setDesktopSizeTo5P5,
                    text: 'setDesktopSizeTo5P5'),
                ElevatedText(
                    onPressed: Curiosity.instance.desktop.setDesktopSizeTo5P8,
                    text: 'setDesktopSizeTo5P8'),
                ElevatedText(
                    onPressed: Curiosity.instance.desktop.setDesktopSizeTo6P1,
                    text: 'setDesktopSizeTo6P1'),
                ElevatedText(
                    onPressed:
                        Curiosity.instance.desktop.setDesktopSizeToIPad11,
                    text: 'setDesktopSizeToIPad11'),
                ElevatedText(
                    onPressed:
                        Curiosity.instance.desktop.setDesktopSizeToIPad10P5,
                    text: 'setDesktopSizeToIPad10P5'),
                ElevatedText(
                    onPressed:
                        Curiosity.instance.desktop.setDesktopSizeToIPad9P7,
                    text: 'setDesktopSizeToIPad9P7'),
              ]),
              const SizedBox(height: 20),
              ElevatedText(
                  onPressed: () async {
                    final Size? size =
                        await Curiosity.instance.desktop.getDesktopWindowSize();
                    text = size.toString();
                    setState(() {});
                  },
                  text: 'getDesktopWindowSize'),
              ElevatedText(
                  onPressed: () => changeState(Curiosity.instance.desktop
                      .setDesktopWindowSize(const Size(600, 600))),
                  text: 'setDesktopWindowSize(600,600)'),
              ElevatedText(
                  onPressed: () => changeState(Curiosity.instance.desktop
                      .setDesktopMinWindowSize(const Size(300, 300))),
                  text: 'setDesktopMinWindowSize(300,300)'),
              ElevatedText(
                  onPressed: () => changeState(Curiosity.instance.desktop
                      .setDesktopMaxWindowSize(const Size(900, 900))),
                  text: 'setDesktopMaxWindowSize(900,900)'),
              ElevatedText(
                  onPressed: () => changeState(
                      Curiosity.instance.desktop.resetDesktopMaxWindowSize()),
                  text: 'resetDesktopMaxWindowSize'),
              ElevatedText(
                  onPressed: () => changeState(
                      Curiosity.instance.desktop.toggleDesktopFullScreen()),
                  text: 'toggleDesktopFullScreen'),
              ElevatedText(
                  onPressed: () => changeState(
                      Curiosity.instance.desktop.setDesktopFullScreen(true)),
                  text: 'setDesktopFullScreen true'),
              ElevatedText(
                  onPressed: () => changeState(
                      Curiosity.instance.desktop.setDesktopFullScreen(false)),
                  text: 'setDesktopFullScreen false'),
              ElevatedText(
                  onPressed: () => changeState(
                      Curiosity.instance.desktop.getDesktopFullScreen()),
                  text: 'getDesktopFullScreen'),
              ElevatedText(
                  onPressed: () =>
                      changeState(Curiosity.instance.desktop.hasDesktopBorders),
                  text: 'hasDesktopBorders'),
              ElevatedText(
                  onPressed: () => changeState(
                      Curiosity.instance.desktop.toggleDesktopBorders()),
                  text: 'toggleDesktopBorders'),
              ElevatedText(
                  onPressed: () => changeState(
                      Curiosity.instance.desktop.setDesktopBorders(true)),
                  text: 'setDesktopBorders'),
              ElevatedText(
                  onPressed: () => changeState(
                      Curiosity.instance.desktop.stayOnTopWithDesktop()),
                  text: 'stayOnTopWithDesktop'),
              ElevatedText(
                  onPressed: () => changeState(
                      Curiosity.instance.desktop.stayOnTopWithDesktop(false)),
                  text: 'stayOnTopWithDesktop (false)'),
              ElevatedText(
                  onPressed: Curiosity.instance.desktop.focusDesktop,
                  text: 'focusDesktop'),
            ]));
  }

  void changeState(Future<dynamic> state) {
    state.then((dynamic value) {
      text = 'hashCode(${state.hashCode}): ' + value.toString();
      setState(() {});
    });
  }
}
