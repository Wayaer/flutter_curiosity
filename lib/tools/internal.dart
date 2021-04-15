import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_curiosity/platform/platform.dart';

final MediaQueryData mediaQueryData = MediaQueryData.fromWindow(window);

/// size → Size 设备尺寸信息，如屏幕的大小，单位 pixels
Size get getWindowSize => mediaQueryData.size;

/// devicePixelRatio → double 单位逻辑像素的设备像素数量，即设备像素比。
/// 这个数字可能不是2的幂，实际上它甚至也可能不是整数。例如，Nexus 6的设备像素比为3.5。
double get getDevicePixelRatio => mediaQueryData.devicePixelRatio;
const int _limitLength = 800;

void log<T>(T msg) {
  final String message = msg.toString();
  if (isDebug) {
    if (message.length < _limitLength) {
      print(msg);
    } else {
      _segmentationLog(message);
    }
  }
}

bool get supportPlatformDesktop {
  if (!isWeb && isDesktop) return true;
  log('Curiosity is not support Platform');
  return false;
}

bool get supportPlatform {
  if (!isWeb && (isMobile || isMacOS)) return true;
  log('Curiosity is not support Platform');
  return false;
}

bool get supportPlatformMobile {
  if (isMobile) return true;
  log('Curiosity is not support Platform');
  return false;
}

void _segmentationLog(String msg) {
  final StringBuffer outStr = StringBuffer();
  for (int index = 0; index < msg.length; index++) {
    outStr.write(msg[index]);
    if (index % _limitLength == 0 && index != 0) {
      print(outStr);
      outStr.clear();
      final int lastIndex = index + 1;
      if (msg.length - lastIndex < _limitLength) {
        final String remainderStr = msg.substring(lastIndex, msg.length);
        print(remainderStr);
        break;
      }
    }
  }
}
