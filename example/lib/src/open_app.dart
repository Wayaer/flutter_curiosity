import 'package:curiosity/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';

class OpenSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    if (isAndroid)
      children.addAll(<Widget>[
        ElevatedText(
            onPressed: () async {
              final bool data = await openAndroidAppMarket(
                  'com.tencent.mobileqq',
                  marketPackageName: 'com.coolapk.market');
              showToast(data.toString());
            },
            text: '跳转Android应用市场-酷安'),
        ElevatedText(
            onPressed: () => openAndroidAppMarket('com.tencent.mobileqq'),
            text: '跳转应用市场'),
        ...AndroidSettingPath.values.builder((AndroidSettingPath value) =>
            ElevatedText(
                onPressed: () => openSystemSetting(path: value),
                text: value.toString()))
      ]);
    if (isIOS)
      children.add(
          const ElevatedText(onPressed: openSystemSetting, text: '跳转系统设置'));
    if (isMacOS)
      children.addAll(MacOSSettingPath.values.builder(
          (MacOSSettingPath value) => ElevatedText(
              onPressed: () => openSystemSetting(macPath: value),
              text: value.toString())));
    return ExtendedScaffold(
        appBar: AppBarText('Open App'),
        body: Universal(isScroll: true, children: children));
  }
}
