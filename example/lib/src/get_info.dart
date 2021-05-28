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
      appBar: AppBarText('App and Device'),
      body: ScrollList.builder(
          header: SliverToBoxAdapter(
              child: Column(children: <Widget>[
            ElevatedText(onPressed: () => getAppInfo(), text: '获取app信息'),
            ElevatedText(onPressed: () => getGPS(), text: '获取gps状态'),
            ElevatedText(onPressed: () => getDeviceInfo(), text: '获取设备信息'),
            if (isAndroid)
              ElevatedText(
                  onPressed: () => getInstalled(), text: '获取Android已安装应用'),
          ])),
          placeholder: Container(
              alignment: Alignment.center,
              child: const Text('暂无数据'),
              margin: const EdgeInsets.symmetric(vertical: 30)),
          itemCount: list.length,
          itemBuilder: (_, int index) => list[index]),
    );
  }

  Future<void> getInstalled() async {
    final List<AppsModel> data = await getInstalledApp();
    list = <Widget>[];
    data.builder((AppsModel appsModel) {
      final Map<String, dynamic> appModel = appsModel.toJson();
      final List<Widget> app = <Widget>[];
      appModel.forEach((String key, dynamic value) {
        app.add(Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Text(key + ' = ' + value.toString())));
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

  Future<void> getDeviceInfo() async {
    list = <Widget>[];
    Map<String, dynamic> map = <String, dynamic>{};
    if (isAndroid) {
      final AndroidDeviceModel? model = await getAndroidDeviceInfo();
      if (model != null) map = model.toJson();
    }
    if (isIOS) {
      final IOSDeviceModel? model = await getIOSDeviceInfo();
      if (model != null) map = model.toJson();
    }
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
    final AppInfoModel? data = await getPackageInfo();
    if (data == null) return;
    final Map<String, dynamic> map = data.toJson();
    list = <Widget>[];
    map.forEach((String key, dynamic value) {
      list.add(showText(key, value));
    });
    setState(() {});
  }

  Future<void> getGPS() async {
    final bool data = await getGPSStatus();
    showToast(data.toString());
  }
}
