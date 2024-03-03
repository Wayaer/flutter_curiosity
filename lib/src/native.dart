part of '../flutter_curiosity.dart';

typedef AndroidActivityResultHandler = void Function(
    AndroidActivityResult result);

typedef KeyboardStatusHandler = void Function(bool visibility);

class NativeTools {
  factory NativeTools() => _singleton ??= NativeTools._();

  NativeTools._() {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'keyboardStatus':
          for (var element in keyboardStatus) {
            element(call.arguments as bool);
          }
          break;
        case 'onActivityResult':
          for (var element in activityResult) {
            element.call(AndroidActivityResult.formJson(
                call.arguments as Map<dynamic, dynamic>));
          }
          break;
      }
    });
  }

  static NativeTools? _singleton;

  /// 添加回调方法
  final List<AndroidActivityResultHandler> activityResult = [];

  /// 添加回调方法
  final List<KeyboardStatusHandler> keyboardStatus = [];

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

  PackageSelfInfo? _packageInfo;

  Future<PackageSelfInfo?> get packageInfo async =>
      _packageInfo ??= await getPackageInfo();

  /// get Android/IOS/MacOS info
  Future<PackageSelfInfo?> getPackageInfo() async {
    if (!_supportPlatform) return null;
    final Map<String, dynamic>? map =
        await _channel.invokeMapMethod<String, dynamic>('getPackageInfo');
    if (map != null) return PackageSelfInfo.fromJson(map);
    return null;
  }

  /// get Android  installed apps
  Future<List<AppPackageInfo>> get getInstalledApps async {
    if (!Curiosity.isAndroid) return [];
    final appList = await _channel
        .invokeListMethod<Map<dynamic, dynamic>>('getInstalledApps');
    final List<AppPackageInfo> list = [];
    if (appList != null) {
      for (final dynamic data in appList) {
        list.add(AppPackageInfo.fromJson(data as Map<dynamic, dynamic>));
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
