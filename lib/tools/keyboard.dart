import 'package:flutter/services.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';

import 'internal.dart';

typedef KeyboardStatus = void Function(bool visibility);

/// android ios  键盘状态监听
void keyboardListener(KeyboardStatus keyboardStatus) {
  if (!supportPlatformMobile) return;
  curiosityChannel.setMethodCallHandler((MethodCall call) async {
    if (call.method != 'keyboardStatus') return;
    return keyboardStatus(call.arguments as bool);
  });
}
