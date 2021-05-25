import 'package:curiosity/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';

class OpenSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      ElevatedText(
          onPressed: () async {
            final bool data = await openAndroidAppMarket('com.tencent.mobileqq',
                marketPackageName: 'com.coolapk.market');
            showToast(data.toString());
          },
          text: '跳转Android应用市场-酷安'),
      ElevatedText(
          onPressed: () => openAndroidAppMarket('com.tencent.mobileqq'),
          text: '跳转应用市场'),
    ];
    children.addAll(SettingType.values
        .map((SettingType value) => ElevatedText(
            onPressed: () => openSystemSetting(value), text: value.toString()))
        .toList());
    return OverlayScaffold(
        appBar: const AppBarText('Android Open Setting'),
        body: Universal(isScroll: true, children: children));
  }
}
