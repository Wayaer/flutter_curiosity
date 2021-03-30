import 'package:flutter/services.dart';

import 'package:flutter_curiosity/flutter_curiosity.dart';

import 'internal.dart';

typedef KeyboardStatus = void Function(bool visibility);

void keyboardListener(KeyboardStatus keyboardStatus) {
  if (!supportPlatform) return;
  curiosityChannel.setMethodCallHandler((MethodCall call) async {
    if (call.method != 'keyboardStatus') return;
    return keyboardStatus(call.arguments as bool);
  });
}
