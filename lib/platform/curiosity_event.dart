import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/tools/internal.dart';

typedef EventListen = void Function(dynamic data);

class CuriosityEvent {
  StreamSubscription<dynamic>? _streamSubscription;
  EventChannel? _eventChannel;
  dynamic eventMessage;

  Future<bool> startEventListen(EventListen eventListen) async {
    try {
      final bool? state =
          await curiosityChannel.invokeMethod<bool?>('startCuriosityEvent');
      log('初始化消息通道==$state');
      if (state ?? false) return false;
      _eventChannel = const EventChannel(curiosityEvent);
      log(_eventChannel!.binaryMessenger.toString());
      _streamSubscription = _eventChannel!
          .receiveBroadcastStream()
          .listen(eventListen, onError: () {
        log('开启消息通道监听失败');
      }, onDone: () {
        log('开启消息通道监听 onDone');
      });
      log('初始化消息通道完成==$state');
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<bool> stopEventListen(EventListen eventListen) async {
    final bool? state =
        await curiosityChannel.invokeMethod<bool?>('stopCuriosityEvent');
    if (state ?? false) return false;
    _streamSubscription?.cancel();
    return true;
  }
}
