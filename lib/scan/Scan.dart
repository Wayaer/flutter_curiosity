// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_curiosity/scan/ScanController.dart';

/// qr scan view , it need to  require camera permission.
class Scan extends StatefulWidget {
  final ScanController controller;
  final int width;
  final int height;

  const Scan({this.controller, this.width, this.height}) : assert(controller != null);

  @override
  State<StatefulWidget> createState() => ScanState();
}

class ScanState extends State<Scan> {
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
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: params,
        creationParamsCodec: StandardMessageCodec(),
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
