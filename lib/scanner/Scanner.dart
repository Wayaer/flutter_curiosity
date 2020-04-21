// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_curiosity/scanner/ScannerController.dart';

class Scanner extends StatefulWidget {
  final ScannerController controller;
  final PlatformViewHitTestBehavior hitTestBehavior;

  //android扫描条形码请横屏即可识别
  //识别区域 比例 0-1
  final double topRatio; //距离屏幕头部
  final double leftRatio; //距离屏幕左边
  final double widthRatio; //识别区域的宽高度比例
  final double heightRatio; //识别区域的宽高度比例
  final bool androidOldCamera; //android 使用旧版Camera 识别率更快
  //屏幕宽度比例=leftRatio + widthRatio + leftRatio
  //屏幕高度比例=topRatio + heightRatio + topRatio

  Scanner({this.controller,
    this.hitTestBehavior =
        PlatformViewHitTestBehavior
            .opaque,
    this.topRatio: 0.3, this.leftRatio: 0.1, this.widthRatio: 0.8, this.heightRatio: 0.4, this.androidOldCamera: false,})
      : assert(leftRatio * 2 + widthRatio == 1),
        assert(topRatio * 2 + heightRatio == 1),
        assert(controller != null);

  @override
  State<StatefulWidget> createState() => ScannerState();
}

class ScannerState extends State<Scanner> {
  ScannerController controller;
  Map<String, dynamic> params;

  onPlatformViewCreated(int id) {
    controller.attach(id);
  }

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? ScannerController();
    params = {
      "androidOldCamera": widget.androidOldCamera,
      "topRatio": widget.topRatio,
      "leftRatio": widget.leftRatio,
      "widthRatio": widget.widthRatio,
      "heightRatio": widget.heightRatio,
    };
  }

  @override
  void dispose() {
    super.dispose();
    controller.detach();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: scanner,
        //与原生交互时唯一标识符，常见形式是包名+自定义名；
        onPlatformViewCreated: onPlatformViewCreated,
        //创建视图后的回调
        hitTestBehavior: widget.hitTestBehavior,
        // 渗透点击事件，接收范围 opaque > translucent > transparent；
        creationParams: params,
        //向视图传递参数，常为 PlatformViewFactory；
//        layoutDirection: TextDirection.ltr,
        // 嵌入视图文本方向；
        creationParamsCodec: StandardMessageCodec(),
        //编解码器类型
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: scanner,
//        hitTestBehavior: widget.hitTestBehavior,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: params,
        creationParamsCodec: StandardMessageCodec(),
      );
    } else {
      return Container(
        child: Text('Not support ${Platform.operatingSystem} platform'),
      );
    }
  }
}
