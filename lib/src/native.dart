part of '../flutter_curiosity.dart';

typedef AndroidActivityResultHandler = void Function(
    AndroidActivityResult result);

typedef NativeKeyboardStatusCallback = void Function(
    NativeKeyboardStatus status);

class NativeTools {
  factory NativeTools() => _singleton ??= NativeTools._();

  NativeTools._() {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onKeyboardStatus':
          for (var element in _keyboardStatus) {
            element(NativeKeyboardStatus.fromMap(call.arguments as Map));
          }
          break;
        case 'onActivityResult':
          for (var element in activityResult) {
            element.call(AndroidActivityResult.fromMap(call.arguments as Map));
          }
          break;
      }
    });
  }

  static NativeTools? _singleton;

  static NativeTools get instance => NativeTools();

  /// 添加键盘回调方法
  final List<NativeKeyboardStatusCallback> _keyboardStatus = [];

  /// add Keyboard listener
  Future<bool> addKeyboardListener(
      NativeKeyboardStatusCallback callback) async {
    if (!_supportPlatform || Curiosity.isMacOS) return false;
    final needCallNative = _keyboardStatus.isEmpty;
    if (!_keyboardStatus.contains(callback)) {
      _keyboardStatus.add(callback);
    }
    if (!needCallNative) return true;
    return (await _channel.invokeMethod<bool>('addKeyboardListener')) ?? false;
  }

  /// remove Keyboard listener
  Future<bool> removeKeyboardListener(
      NativeKeyboardStatusCallback callback) async {
    if (!_supportPlatform || Curiosity.isMacOS) return false;
    _keyboardStatus.remove(callback);
    if (_keyboardStatus.isEmpty) return true;
    return (await _channel.invokeMethod<bool>('removeKeyboardListener')) ??
        false;
  }

  /// 添加回调方法
  final List<AndroidActivityResultHandler> activityResult = [];

  /// 判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
  Future<bool> get gpsStatus async {
    if (!_supportPlatform) return false;
    return await _channel.invokeMethod('getGPSStatus') ?? false;
  }

  /// Exit app
  Future<bool?> exitApp() async {
    if (!_supportPlatform) return false;
    return await _channel.invokeMethod<bool>('exitApp') ?? false;
  }

  /// get Android  installed apps
  Future<List<AppPackageInfo>> get getInstalledApps async {
    if (!Curiosity.isAndroid) return [];
    final appList = await _channel
        .invokeListMethod<Map<dynamic, dynamic>>('getInstalledApps');
    final List<AppPackageInfo> list = [];
    if (appList != null) {
      for (final dynamic data in appList) {
        list.add(AppPackageInfo.fromMap(data as Map));
      }
    }
    return list;
  }

  /// 安装apk  仅支持android
  /// Installing APK only supports Android
  Future<bool> installApk(String path) async {
    if (!Curiosity.isAndroid) return false;
    final result = await _channel.invokeMethod<bool?>('installApk', path);
    return result ?? false;
  }
}
