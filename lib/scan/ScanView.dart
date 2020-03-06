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

  //识别区域 比例 0-1 默认全屏幕识别
  double topRatio;//距离屏幕头部
  double leftRatio;//距离屏幕左边
  double widthRatio;//宽度
  double heightRatio;//高度

  ScanView({this.controller, this.topRatio: 0, this.leftRatio: 0, this.widthRatio: 1, this.heightRatio: 1, this.hitTestBehavior =
      PlatformViewHitTestBehavior
          .opaque,}) {
    assert(controller != null);
  }

  @override
  State<StatefulWidget> createState() => ScanViewState();
}

class ScanViewState extends State<ScanView> {
  ScanController controller;
  Map<String, dynamic> params;

  void onPlatformViewCreated(int id) {
    controller.attach(id);
  }

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? ScanController();
    params = {
      "isPlay": controller.isPlay,
      "width": (Utils
          .getSize()
          .width * Utils.getDevicePixelRatio()).toInt(),
      "height": (Utils
          .getSize()
          .height * Utils.getDevicePixelRatio()).toInt(),
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
        child: Text('Not support ${Platform.operatingSystem} platform.'),
      );
    }
  }
}
