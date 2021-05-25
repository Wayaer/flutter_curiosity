import 'package:curiosity/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';

class OpenSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];

    children.addAll(SettingType.values
        .map((SettingType value) => ElevatedText(
            onPressed: () => openSystemSetting(value), text: value.toString()))
        .toList());
    return OverlayScaffold(
        appBar: const AppBarText('Android Jump Setting'),
        body: Universal(isScroll: true, children: children));
  }
}

class OpenAppPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const String url = 'https://pub.dev/flutter/packages';
    return OverlayScaffold(
        appBar: const AppBarText('Android Jump Setting'),
        body: Universal(children: <Widget>[
          ElevatedText(
              onPressed: () async {
                if (await canOpenUrl(url)) {
                  print('打开url');
                  final bool data = await openUrl(url);
                  print('打开了url $data');
                } else {
                  print('不能打开url');
                }
              },
              text: '打开网页 $url'),
          if (isAndroid)
            ElevatedText(
                onPressed: () async {
                  final bool data = await openAppStore('com.tencent.mobileqq',
                      marketPackageName: 'com.coolapk.market');
                  showToast(data.toString());
                },
                text: '跳转Android应用市场-酷安'),
          ElevatedText(
              onPressed: () => openAppStore(
                  isAndroid ? 'com.tencent.mobileqq' : '444934666'),
              text: '跳转应用市场'),
          ElevatedText(onPressed: () => openPhone('10086'), text: '电话'),
          ElevatedText(onPressed: () => openSMS('10086'), text: '短信'),
        ]));
  }
}
