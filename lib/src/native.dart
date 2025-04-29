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
            element(NativeKeyboardStatus.formMap(call.arguments as Map));
          }
          break;
        case 'onActivityResult':
          for (var element in activityResult) {
            element.call(AndroidActivityResult.formMap(call.arguments as Map));
          }
          break;
      }
    });
  }

  static NativeTools? _singleton;

  /// 添加键盘回调方法
  final List<NativeKeyboardStatusCallback> _keyboardStatus = [];

  /// add Keyboard listener
  Future<bool> addKeyboardListener(
      NativeKeyboardStatusCallback callback) async {
    if (!_supportPlatform) return false;
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
    if (!_supportPlatform) return false;
    _keyboardStatus.remove(callback);
    if (_keyboardStatus.isNotEmpty) return true;
    return (await _channel.invokeMethod<bool>('removeKeyboardListener')) ??
        false;
  }

  /// 添加回调方法
  final List<AndroidActivityResultHandler> activityResult = [];

  /// 判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
  Future<bool> get gpsStatus async {
    if (!_supportPlatform) return false;
    final bool? state = await _channel.invokeMethod('getGPSStatus');
    return state ?? false;
  }

  /// Exit app
  Future<void> exitApp() async {
    if (!_supportPlatform) return;
    await _channel.invokeMethod<dynamic>('exitApp');
  }

  /// get Android  installed apps
  Future<List<AppPackageInfo>> get getInstalledApps async {
    if (!Curiosity.isAndroid) return [];
    final appList = await _channel
        .invokeListMethod<Map<dynamic, dynamic>>('getInstalledApps');
    final List<AppPackageInfo> list = [];
    if (appList != null) {
      for (final dynamic data in appList) {
        list.add(AppPackageInfo.formMap(data as Map));
      }
    }
    return list;
  }

  /// 安装apk  仅支持android
  /// Installing APK only supports Android
  Future<bool> installApk(String apkPath) async {
    if (!Curiosity.isAndroid) return false;
    final result = await _channel.invokeMethod<bool?>('installApk', apkPath);
    return result ?? false;
  }
}
