import 'package:curiosity/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';

class DesktopPage extends StatefulWidget {
  const DesktopPage({super.key});

  @override
  State<DesktopPage> createState() => _DesktopPageState();
}

class _DesktopPageState extends State<DesktopPage> {
  String text = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText(''),
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
              Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  children: DesktopWindowsSize.values.builder((size) =>
                      ElevatedText(
                          onPressed: size.set,
                          text: 'setSizeTo ${size.name}'))),
              const SizedBox(height: 20),
              ElevatedText(
                  onPressed: () async {
                    final Size? size =
                        await Curiosity().desktop.getWindowSize();
                    text = size.toString();
                    setState(() {});
                  },
                  text: 'getWindowSize'),
              ElevatedText(
                  onPressed: () => changeState(
                      Curiosity().desktop.setWindowSize(const Size(600, 600))),
                  text: 'setWindowSize(600,600)'),
              ElevatedText(
                  onPressed: () => changeState(Curiosity()
                      .desktop
                      .setMinWindowSize(const Size(300, 300))),
                  text: 'setMinWindowSize(300,300)'),
              ElevatedText(
                  onPressed: () => changeState(Curiosity()
                      .desktop
                      .setMaxWindowSize(const Size(900, 900))),
                  text: 'setMaxWindowSize(900,900)'),
              ElevatedText(
                  onPressed: () =>
                      changeState(Curiosity().desktop.resetMaxWindowSize()),
                  text: 'resetMaxWindowSize'),
              ElevatedText(
                  onPressed: () =>
                      changeState(Curiosity().desktop.toggleFullScreen()),
                  text: 'toggleFullScreen'),
              ElevatedText(
                  onPressed: () =>
                      changeState(Curiosity().desktop.setFullScreen(true)),
                  text: 'setFullScreen true'),
              ElevatedText(
                  onPressed: () =>
                      changeState(Curiosity().desktop.setFullScreen(false)),
                  text: 'setFullScreen false'),
              ElevatedText(
                  onPressed: () =>
                      changeState(Curiosity().desktop.getFullScreen()),
                  text: 'getFullScreen'),
              ElevatedText(
                  onPressed: () => changeState(Curiosity().desktop.hasBorders),
                  text: 'hasBorders'),
              ElevatedText(
                  onPressed: () =>
                      changeState(Curiosity().desktop.toggleBorders()),
                  text: 'toggleBorders'),
              ElevatedText(
                  onPressed: () =>
                      changeState(Curiosity().desktop.setBorders(true)),
                  text: 'setBorders'),
              ElevatedText(
                  onPressed: () => changeState(Curiosity().desktop.stayOnTop()),
                  text: 'stayOnTopWith'),
              ElevatedText(
                  onPressed: () =>
                      changeState(Curiosity().desktop.stayOnTop(false)),
                  text: 'stayOnTopWith (false)'),
              ElevatedText(onPressed: Curiosity().desktop.focus, text: 'focus'),
            ]));
  }

  void changeState(Future<dynamic> state) {
    state.then((dynamic value) {
      text = 'hashCode(${state.hashCode}): $value';
      setState(() {});
    });
  }
}
