import 'package:curiosity/main.dart';
import 'package:fl_extended/fl_extended.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';

class GetInfoPage extends StatefulWidget {
  const GetInfoPage({super.key});

  @override
  State<GetInfoPage> createState() => _GetInfoPageState();
}

class _GetInfoPageState extends State<GetInfoPage> {
  List<Widget> list = <Widget>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarText('App and Device'),
        body: CustomScrollView(slivers: [
          SliverToBoxAdapter(
              child: Column(children: <Widget>[
            ElevatedText(onPressed: getGPS, text: '获取gps状态'),
            if (Curiosity.isAndroid)
              ElevatedText(
                  onPressed: () => getInstalledApps(), text: '获取Android已安装应用'),
          ])),
          SliverList.builder(
              itemCount: list.length,
              itemBuilder: (_, int index) => list[index])
        ]));
  }

  Future<void> getInstalledApps() async {
    final data = await Curiosity.native.getInstalledApps;
    list = [];
    data.builder((appsModel) {
      final Map<String, dynamic> appModel = appsModel.toMap();
      final List<Widget> app = [];
      appModel.forEach((String key, dynamic value) {
        app.add(Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Text('$key = $value')));
      });
      list.add(Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 15),
        padding: const EdgeInsets.only(bottom: 10),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey))),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: app),
      ));
    });
    setState(() {});
  }

  Future<void> getGPS() async {
    final bool data = await Curiosity.native.gpsStatus;
    showToast(data.toString());
  }
}
