import 'dart:async';

import 'package:flutter/services.dart';

class FlutterCuriosity {
  static const MethodChannel _channel =
      const MethodChannel('FlutterCuriosity');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
