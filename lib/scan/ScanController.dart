import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_curiosity/constant/Constant.dart';

const scanView = 'scanView';

class ScanController extends ChangeNotifier {
  StreamSubscription subscription;
  String code;
  String type;
  bool isScan;
  MethodChannel channel;

  ScanController({this.isScan: true})
      : assert(isScan != null),
        super();

  void attach(int id) {
    channel = MethodChannel('$scanView/$id/method');
    subscription = EventChannel('$scanView/$id/event').receiveBroadcastStream({ "isScan": isScan}).listen((data) {
      this.code = data['code'];
      this.type = data['type'];
      notifyListeners();
    });
  }

  Future<void> startScan() async => await channel.invokeMethod('startScan');

  Future<void> stopScan() async => await channel.invokeMethod('stopScan');

  Future<bool> setFlashMode(bool status) async {
    return await methodChannel.invokeMethod('setFlashMode', {'status': status ?? false});
  }

  Future<bool> getFlashMode() async {
    return await methodChannel.invokeMethod('getFlashMode');
  }

  static Future<String> scanImagePath(String path) async {
    return await methodChannel.invokeMethod('scanImagePath', { "path": path});
  }

  static Future<String> scanImageUrl(String url) async {
    return await methodChannel.invokeMethod('scanImageUrl', { "url": url});
  }

  static Future<String> scanImageMemory(Uint8List uint8list) async {
    return await methodChannel.invokeMethod('scanImageMemory', { "uint8list": uint8list});
  }

  void detach() {
    subscription?.cancel();
    notifyListeners();
  }
}
