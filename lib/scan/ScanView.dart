// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_curiosity/scan/ScanController.dart';
import 'package:flutter_curiosity/utils/Utils.dart';

class ScanView extends StatefulWidget {
  final ScanController controller;
  int width;
  int height;

  ScanView({this.controller, this.width, this.height}) {
    assert(controller != null);
    if (width == null) {
      width = (Utils
          .getSize()
          .width * Utils.getDevicePixelRatio()).toInt();
      height = (Utils
          .getSize()
          .height * Utils.getDevicePixelRatio()).toInt();
    }
  }

  @override
  State<StatefulWidget> createState() => ScanViewState();
}

class ScanViewState extends State<ScanView> {
  ScanController controller;

  void onPlatformViewCreated(int id) {
    controller.attach(id);
  }

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? ScanController();
  }

  @override
  void dispose() {
    super.dispose();
    controller.detach();
  }

  @override
  Widget build(BuildContext context) {
    dynamic params = {"isPlay": controller.isPlay, "width": widget.width, "height": widget.height};
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: scanView,
        //与原生交互时唯一标识符，常见形式是包名+自定义名；
        onPlatformViewCreated: onPlatformViewCreated,
        //创建视图后的回调
//        hitTestBehavior: null,
        // 渗透点击事件，接收范围 opaque > translucent > transparent；
        creationParams: params,
        //向视图传递参数，常为 PlatformViewFactory；
//        layoutDirection: null,
        // 嵌入视图文本方向；
        creationParamsCodec: StandardMessageCodec(),
        //编解码器类型
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: scanView,
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
