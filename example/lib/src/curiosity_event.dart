import 'package:curiosity/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';

class CuriosityEventPage extends StatefulWidget {
  const CuriosityEventPage({Key? key}) : super(key: key);

  @override
  _CuriosityEventPageState createState() => _CuriosityEventPageState();
}

class _CuriosityEventPageState extends State<CuriosityEventPage> {
  String state = '未初始化';
  List<String> text = [];
  CuriosityEvent? event;

  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
        appBar: AppBarText('CuriosityEvent 消息通道'),
        body: Universal( children: <Widget>[
          showText('state', state),
          ElevatedText(onPressed: start, text: '注册消息通道'),
          ElevatedText(onPressed: send, text: '发送消息'),
          ElevatedText(onPressed: stop, text: '销毁消息通道'),
          const SizedBox(height: 20),
          ListView.builder(
              itemCount: text.length,
              itemBuilder: (BuildContext context, int index) =>
                  showText(index, text[index])).expandedNull
        ]));
  }

  Future<void> start() async {
    event = CuriosityEvent.instance;
    log(event.hashCode);
    final bool eventState = await event!.initialize();
    if (eventState) {
      state = '初始化成功';
      setState(() {});
      event!.addListener((dynamic data) {
        text.add(data.toString());
        setState(() {});
      });
    }
  }

  Future<void> send() async {
    final bool? status = await event?.sendEvent('这条消息是从Flutter 传递到原生');
    state = (status ?? false) ? '发送成功' : '发送失败';
    setState(() {});
  }

  Future<void> stop() async {
    final bool? status = await event?.dispose();
    state = (status ?? false) ? '已销毁' : '销毁失败';
    text = [];
    setState(() {});
  }
}
