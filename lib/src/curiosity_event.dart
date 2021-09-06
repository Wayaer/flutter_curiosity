import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_curiosity/src/internal.dart';

typedef EventListen = void Function(dynamic data);

class CuriosityEvent {
  factory CuriosityEvent() {
    _singleton ??= CuriosityEvent._();
    return _singleton!;
  }

  CuriosityEvent._();

  static CuriosityEvent? _singleton;

  /// 订阅流
  StreamSubscription<dynamic>? _streamSubscription;

  /// 创建流
  Stream<dynamic>? _stream;

  /// 消息通道
  EventChannel? _eventChannel;

  bool get isPaused =>
      _streamSubscription != null && _streamSubscription!.isPaused;

  /// 初始化消息通道
  Future<bool> initialize() async {
    if (!supportPlatform) return false;
    bool? state = await channel.invokeMethod<bool?>('startCuriosityEvent');
    state ??= false;
    if (state && _eventChannel == null) {
      _eventChannel = const EventChannel(curiosityEvent);
      _stream = _eventChannel?.receiveBroadcastStream(<dynamic, dynamic>{});
    }
    return state && _eventChannel != null && _stream != null;
  }

  /// 添加消息流监听
  Future<bool> addListener(EventListen eventListen) async {
    if (!supportPlatform) return false;
    if (_eventChannel != null && _stream != null) {
      if (_streamSubscription != null) return false;
      try {
        _streamSubscription = _stream!.listen(eventListen);
        return true;
      } catch (e) {
        log(e);
        return false;
      }
    }
    return false;
  }

  /// 调用原生方法 发送消息
  Future<bool> sendEvent(dynamic arguments) async {
    if (!supportPlatform) return false;
    if (_eventChannel == null ||
        _streamSubscription == null ||
        _streamSubscription!.isPaused) return false;
    final bool? state =
        await channel.invokeMethod<bool?>('sendCuriosityEvent', arguments);
    return state ?? false;
  }

  /// 暂停消息流监听
  bool pause() {
    if (!supportPlatform) return false;
    if (_streamSubscription != null && !_streamSubscription!.isPaused) {
      _streamSubscription!.pause();
      return true;
    }
    return false;
  }

  /// 重新开始监听
  bool resume() {
    if (!supportPlatform) return false;
    if (_streamSubscription != null && _streamSubscription!.isPaused) {
      _streamSubscription!.resume();
      return true;
    }
    return false;
  }

  /// 关闭并销毁消息通道
  Future<bool> dispose() async {
    if (!supportPlatform) return false;
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    _stream = null;
    _eventChannel = null;
    final bool? state = await channel.invokeMethod<bool>('stopCuriosityEvent');
    return state ?? false;
  }
}
