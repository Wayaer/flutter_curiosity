import 'package:curiosity/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';

class GetInfoPage extends StatefulWidget {
  const GetInfoPage({Key? key}) : super(key: key);

  @override
  State<GetInfoPage> createState() => _GetInfoPageState();
}

class _GetInfoPageState extends State<GetInfoPage> {
  List<Widget> list = <Widget>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarText('App and Device'),
      body: ScrollList.builder(
          header: SliverToBoxAdapter(
              child: Column(children: <Widget>[
            ElevatedText(onPressed: getGPS, text: '获取gps状态'),
            ElevatedText(onPressed: appInfo, text: '获取app信息'),
            ElevatedText(onPressed: appPath, text: '获取app存储路径'),
            ElevatedText(onPressed: deviceInfo, text: '获取设备信息'),
            if (isAndroid)
              ElevatedText(
                  onPressed: () => getInstalled(), text: '获取Android已安装应用'),
          ])),
          placeholder: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(vertical: 30),
              child: const Text('暂无数据')),
          itemCount: list.length,
          itemBuilder: (_, int index) => list[index]),
    );
  }

  Future<void> getInstalled() async {
    final List<AppsModel> data = await Curiosity().native.installedApp;
    list = <Widget>[];
    data.builder((AppsModel appsModel) {
      final Map<String, dynamic> appModel = appsModel.toMap();
      final List<Widget> app = <Widget>[];
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

  Future<void> deviceInfo() async {
    final DeviceInfoModel? model = await Curiosity().native.deviceInfo;
    list.clear();
    model?.toMap().forEach((String key, dynamic value) {
      if (value is Map) {
        list.add(const ShowText('=== uts', '==='));
        value.forEach((dynamic k, dynamic v) {
          list.add(ShowText('  $k', v));
        });
        list.add(const ShowText('=== uts', '==='));
      } else {
        list.add(ShowText(key, value));
      }
    });
    setState(() {});
  }

  Future<void> appPath() async {
    final AppPathModel? data = await Curiosity().native.appPath;
    if (data == null) return;
    list.clear();
    data.toMap().forEach((String key, dynamic value) {
      list.add(ShowText(key, value));
    });
    setState(() {});
  }

  Future<void> appInfo() async {
    final AppInfoModel? data = await Curiosity().native.appInfo;
    if (data == null) return;
    list.clear();
    data.toMap().forEach((String key, dynamic value) {
      list.add(ShowText(key, value));
    });
    setState(() {});
  }

  Future<void> getGPS() async {
    final bool data = await Curiosity().native.gpsStatus;
    showToast(data.toString());
  }
}
