import 'package:curiosity/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';

class GetInfoPage extends StatefulWidget {
  @override
  _GetInfoPageState createState() => _GetInfoPageState();
}

class _GetInfoPageState extends State<GetInfoPage> {
  List<Widget> list = <Widget>[];

  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
        appBar: AppBar(title: const Text('App and Device')),
        body: Universal(isScroll: true, children: <Widget>[
          ElevatedButton(
              onPressed: () => getAppInfo(), child: const Text('获取app信息')),
          ElevatedButton(onPressed: () => getGPS(), child: const Text('获取gps状态')),
          ElevatedButton(
              onPressed: () => getDeviceInfo(), child: const Text('获取设备信息')),
          ElevatedButton(
              onPressed: () => getInstalled(),
              child: const Text('获取Android已安装应用')),
          Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: list),
        ]));
  }

  Future<void> getInstalled() async {
    final List<AppsModel> data = await getInstalledApp;
    list = <Widget>[];
    data?.builder((AppsModel appsModel) {
      final Map<String, dynamic> appModel = appsModel.toJson();
      final List<Widget> app = <Widget>[];
      appModel.forEach((String key, dynamic value) {
        app.add(Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Text(key + ' = ' + value.toString())));
      });
      list.add(Universal(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 15),
          padding: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey))),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: app));
    });
    setState(() {});
  }

  Future<void> getDeviceInfo() async {
    list = <Widget>[];
    Map<String, dynamic> map = <String, dynamic>{};
    if (isAndroid) map = (await getAndroidDeviceInfo).toJson();
    if (isIOS) map = (await getIOSDeviceInfo).toJson();
    map.forEach((String key, dynamic value) {
      if (value is Map) {
        list.add(showText('=== uts', '==='));
        value.forEach((dynamic k, dynamic v) {
          list.add(showText(k, v));
        });
        list.add(showText('=== uts', '==='));
      } else {
        list.add(showText(key, value));
      }
    });
    setState(() {});
  }

  Future<void> getAppInfo() async {
    final AppInfoModel data = await getPackageInfo;
    final Map<String, dynamic> map = data.toJson();
    list = <Widget>[];
    map.forEach((String key, dynamic value) {
      list.add(showText(key, value));
    });
    setState(() {});
  }

  Future<void> getGPS() async {
    final bool data = await getGPSStatus;
    showToast(data.toString());
  }
}
