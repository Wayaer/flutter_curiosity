import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';

typedef EventListen = void Function(dynamic data);

class CuriosityEvent {
  factory CuriosityEvent() => _getInstance();

  CuriosityEvent._internal();

  static CuriosityEvent get instance => _getInstance();
  static CuriosityEvent? _instance;

  static CuriosityEvent _getInstance() {
    _instance ??= CuriosityEvent._internal();
    return _instance!;
  }

  StreamSubscription<dynamic>? _streamSubscription;
  EventChannel? _eventChannel;
  dynamic eventMessage;

  bool get isPaused =>
      _streamSubscription != null && _streamSubscription!.isPaused;

  /// 初始化消息通道
  Future<bool> initialize() async {
    bool? state =
        await curiosityChannel.invokeMethod<bool?>('startCuriosityEvent');
    state ??= false;
    if (state) _eventChannel = const EventChannel(curiosityEvent);
    return state && (_eventChannel != null);
  }

  /// 添加消息流监听
  bool addListener(EventListen eventListen) {
    if (_eventChannel == null) return false;
    _streamSubscription = _eventChannel
        ?.receiveBroadcastStream(<dynamic, dynamic>{}).listen(eventListen);
    return true;
  }

  /// 暂停消息流监听
  bool pause(EventListen eventListen) {
    if (_streamSubscription == null) return false;
    _streamSubscription!.pause();
    return true;
  }

  /// 重新开始监听
  bool resume(EventListen eventListen) {
    if (_streamSubscription == null) return false;
    _streamSubscription!.resume();
    return true;
  }

  /// 移出监听
  Future<bool> removeListener() async {
    if (_streamSubscription == null) return false;
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    return true;
  }

  /// 关闭并销毁消息通道
  Future<bool> dispose() async {
    if (_streamSubscription != null) removeListener();
    final bool? state =
        await curiosityChannel.invokeMethod<bool>('stopCuriosityEvent');
    return state ?? false;
  }
}
