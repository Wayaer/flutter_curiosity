import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_curiosity/constant/Constant.dart';

class ScannerController extends ChangeNotifier {
  StreamSubscription subscription;
  String code;
  String type;

  void start(int id) {
    MethodChannel('$scanner/$id/method');
    subscription =
        EventChannel('$scanner/$id/event').receiveBroadcastStream({}).listen((
            data) {
          this.code = data['code'];
          this.type = data['type'];
          notifyListeners();
        });
  }

  Future<bool> setFlashMode(bool status) async {
    return await curiosityChannel.invokeMethod(
        'setFlashMode', {'status': status});
  }

  static Future<String> scanImagePath(String path) async {
    return await curiosityChannel.invokeMethod('scanImagePath', {"path": path});
  }

  static Future<String> scanImageUrl(String url) async {
    return await curiosityChannel.invokeMethod('scanImageUrl', {"url": url});
  }

  static Future<String> scanImageMemory(Uint8List uint8list) async {
    return await curiosityChannel.invokeMethod(
        'scanImageMemory', {"uint8list": uint8list});
  }

  void stop() {
    subscription?.cancel();
    notifyListeners();
  }
}
