// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_curiosity/constant/Constant.dart';
import 'package:flutter_curiosity/scan/CameraScansController.dart';
import 'package:flutter_curiosity/scan/CameraScansResult.dart';

/// qr scan view , it need to  require camera permission.
class CameraScansWidget extends StatefulWidget {
  final CameraScansController controller;

  const CameraScansWidget({this.controller}) : assert(controller != null);

  @override
  State<StatefulWidget> createState() => CameraScansState();
}
const cameraScansViewType = 'CuriosityCameraScansView';
class CameraScansState extends State<CameraScansWidget> {
  CameraScansController controller;

  void onPlatformViewCreated(int id) {
    controller.attach(id);
  }

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? CameraScansController();
  }

  @override
  void dispose() {
    super.dispose();
    controller.detach();
  }

  @override
  Widget build(BuildContext context) {
    dynamic params = {
      "isPlay": controller.isPlay,
    };
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: cameraScansViewType,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: params,
        creationParamsCodec: StandardMessageCodec(),
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: cameraScansViewType,
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

