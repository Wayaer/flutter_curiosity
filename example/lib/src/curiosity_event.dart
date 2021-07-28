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
  String stateText = '未初始化';
  ValueNotifier<List<String>> text = ValueNotifier<List<String>>(<String>[]);
  CuriosityEvent? event;

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        appBar: AppBarText('CuriosityEvent 消息通道'),
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          ShowText('state', stateText),
          Universal(
              width: double.infinity,
              wrapSpacing: 15,
              wrapAlignment: WrapAlignment.center,
              direction: Axis.horizontal,
              isWrap: true,
              children: <Widget>[
                ElevatedText(onPressed: start, text: '注册消息通道'),
                ElevatedText(
                    onPressed: () async {
                      final bool? state =
                          await event?.addListener((dynamic data) {
                        text.value.add(data.toString());
                      });
                      stateText = '添加监听 $state';
                      setState(() {});
                    },
                    text: '添加消息监听'),
                ElevatedText(onPressed: send, text: '发送消息'),
                ElevatedText(
                    onPressed: () {
                      final bool? state = event?.pause();
                      stateText = '暂停消息流监听 $state';
                      setState(() {});
                    },
                    text: '暂停消息流监听'),
                ElevatedText(
                    onPressed: () {
                      final bool? state = event?.resume();
                      stateText = '重新开始监听 $state';
                      setState(() {});
                    },
                    text: '重新开始监听'),
                ElevatedText(onPressed: stop, text: '销毁消息通道'),
              ]),
          const SizedBox(height: 20),
          ValueListenableBuilder<List<String>>(
              valueListenable: text,
              builder: (_, List<String> value, __) {
                return ListView.builder(
                    reverse: true,
                    itemCount: value.length,
                    itemBuilder: (BuildContext context, int index) =>
                        ShowText(index, value[index]));
              }).expandedNull
        ]);
  }

  Future<void> start() async {
    event = CuriosityEvent.instance;
    final bool eventState = await event!.initialize();
    if (eventState) {
      stateText = '初始化成功';
      setState(() {});
    }
  }

  Future<void> send() async {
    final bool? status = await event?.sendEvent('这条消息是从Flutter 传递到原生');
    stateText = (status ?? false) ? '发送成功' : '发送失败';
    setState(() {});
  }

  Future<void> stop() async {
    final bool? status = await event?.dispose();
    stateText = (status ?? false) ? '已销毁' : '销毁失败';
    text.value.clear();
    setState(() {});
  }
}
