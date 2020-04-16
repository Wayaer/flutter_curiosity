// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_curiosity/scan/ScanController.dart';
import 'package:flutter_curiosity/utils/Utils.dart';

class ScanView extends StatefulWidget {
  final ScanController controller;
  final PlatformViewHitTestBehavior hitTestBehavior;
  final bool androidFullScreen;

  //android扫描条形码请横屏即可识别
  //识别区域 比例 0-1 默认全屏幕识别
  final double topRatio; //距离屏幕头部
  final double leftRatio; //距离屏幕左边
  final double widthRatio; //识别区域的宽高度比例
// final double heightRatio; //识别区域的高度比例

  ScanView({this.controller,
    this.androidFullScreen: false,
    this.hitTestBehavior =
        PlatformViewHitTestBehavior
            .opaque,})
      : this.topRatio=0.2,
        this.leftRatio=0.2,
        this.widthRatio=0.8,
        assert(controller != null);

  @override
  State<StatefulWidget> createState() => ScanViewState();
}

class ScanViewState extends State<ScanView> {
  ScanController controller;
  Map<String, dynamic> params;

  onPlatformViewCreated(int id) {
    controller.attach(id);
  }

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? ScanController();
    params = {
      "isScan": controller.isScan,
      "androidFullScreen": widget.androidFullScreen,
      "topRatio": (widget.topRatio * 10).toInt(),
      "leftRatio": (widget.leftRatio * 10).toInt(),
      "widthRatio": (widget.widthRatio * 10).toInt(),
      "heightRatio": ((widget.widthRatio * Utils
          .getSize()
          .width / Utils
          .getSize()
          .height) * 10).roundToDouble().toInt(),
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
        viewType: scanView,
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
        viewType: scanView,
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
