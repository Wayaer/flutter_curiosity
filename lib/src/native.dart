part of '../flutter_curiosity.dart';

/// Signature of [NativeTools.activityResult] callbacks.
typedef AndroidActivityResultHandler = void Function(AndroidActivityResult result);

/// Signature of [NativeTools] keyboard status callbacks.
typedef NativeKeyboardStatusCallback = void Function(NativeKeyboardStatus status);

/// Native methods shared by Android, iOS, macOS and HarmonyOS.
class NativeTools {
  /// Returns the shared [NativeTools] instance.
  factory NativeTools() => instance;

  NativeTools._() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// The shared [NativeTools] instance.
  static final NativeTools instance = NativeTools._();

  final List<NativeKeyboardStatusCallback> _keyboardStatus = [];

  /// Activity result listeners. Only supported on Android.
  final List<AndroidActivityResultHandler> activityResult = [];

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onKeyboardStatus':
        final Map<dynamic, dynamic>? arguments = _argumentsOf(call.arguments);
        if (arguments == null) return;
        _notifyKeyboardStatus(arguments);
        break;
      case 'onActivityResult':
        final Map<dynamic, dynamic>? arguments = _argumentsOf(call.arguments);
        if (arguments == null) return;
        final AndroidActivityResult result = AndroidActivityResult.fromMap(arguments);
        for (final AndroidActivityResultHandler handler in List.of(activityResult)) {
          handler(result);
        }
        break;
    }
  }

  /// Notifies all keyboard listeners with [arguments].
  void _notifyKeyboardStatus(Map<dynamic, dynamic> arguments) {
    final NativeKeyboardStatus status = NativeKeyboardStatus.fromMap(arguments);
    for (final NativeKeyboardStatusCallback callback in List.of(_keyboardStatus)) {
      callback(status);
    }
  }

  /// Returns [arguments] when it is a map, otherwise logs and returns null.
  Map<dynamic, dynamic>? _argumentsOf(dynamic arguments) {
    if (arguments is Map) return arguments;
    debugPrint('Curiosity received unexpected arguments: $arguments');
    return null;
  }

  /// Adds a keyboard status listener.
  ///
  /// Supported on Android, iOS, HarmonyOS and web.
  /// Returns `false` when the current platform does not support keyboard status.
  Future<bool> addKeyboardListener(NativeKeyboardStatusCallback callback) async {
    if (Curiosity.isWeb) {
      if (_keyboardStatus.contains(callback)) return true;
      final bool needWebListener = _keyboardStatus.isEmpty;
      _keyboardStatus.add(callback);
      if (!needWebListener) return true;
      final bool success = WebPlatform.addKeyboardListener(_notifyKeyboardStatus);
      if (!success) _keyboardStatus.remove(callback);
      return success;
    }
    if (Curiosity.isWindows || Curiosity.isLinux || Curiosity.isMacOS) return false;
    if (!_supportPlatform) return false;
    if (_keyboardStatus.contains(callback)) return true;
    final bool needNativeCall = _keyboardStatus.isEmpty;
    _keyboardStatus.add(callback);
    if (!needNativeCall) return true;
    final bool success = await _channel.invokeMethod<bool>('addKeyboardListener') ?? false;
    if (!success) _keyboardStatus.remove(callback);
    return success;
  }

  /// Removes a keyboard status listener.
  ///
  /// Returns `false` when the current platform does not support keyboard status.
  Future<bool> removeKeyboardListener(NativeKeyboardStatusCallback callback) async {
    if (Curiosity.isWeb) {
      if (!_keyboardStatus.remove(callback)) return true;
      if (_keyboardStatus.isNotEmpty) return true;
      WebPlatform.removeKeyboardListener();
      return true;
    }
    if (Curiosity.isWindows || Curiosity.isLinux || Curiosity.isMacOS) return false;
    if (!_supportPlatform) return false;
    if (!_keyboardStatus.remove(callback)) return true;
    if (_keyboardStatus.isNotEmpty) return true;
    return await _channel.invokeMethod<bool>('removeKeyboardListener') ?? false;
  }

  /// Whether GPS is enabled.
  ///
  /// Supported on Android, iOS and HarmonyOS.
  /// On web this returns whether the geolocation permission is granted.
  Future<bool> get gpsStatus async {
    if (Curiosity.isWeb) return WebPlatform.getGpsStatus();
    if (Curiosity.isWindows || Curiosity.isLinux) return false;
    if (!_supportPlatform) return false;
    return await _channel.invokeMethod<bool>('getGPSStatus') ?? false;
  }

  /// Exits the app.
  ///
  /// Supported on Android, iOS, macOS, HarmonyOS, Windows, Linux and web.
  /// On web this is best-effort and only works for script-opened windows.
  Future<bool?> exitApp() async {
    if (Curiosity.isWeb) return WebPlatform.exitApp();
    if (Curiosity.isWindows || Curiosity.isLinux) return IoPlatform.exitApp();
    if (!_supportPlatform) return false;
    return await _channel.invokeMethod<bool>('exitApp') ?? false;
  }

  /// Returns the apps installed on Android.
  Future<List<AppPackageInfo>> get getInstalledApps async {
    if (!Curiosity.isAndroid) return <AppPackageInfo>[];
    final List<Map<dynamic, dynamic>>? appList = await _channel.invokeListMethod<Map<dynamic, dynamic>>(
      'getInstalledApps',
    );
    if (appList == null) return <AppPackageInfo>[];
    return <AppPackageInfo>[for (final Map<dynamic, dynamic> data in appList) AppPackageInfo.fromMap(data)];
  }

  /// Returns the package info of [packageName].
  ///
  /// Only supported on Android.
  Future<AppPackageInfo?> getPackageInfo(String packageName) async {
    if (!Curiosity.isAndroid) return null;
    final Map<dynamic, dynamic>? map = await _channel.invokeMapMethod('getPackageInfo', packageName);
    if (map == null) return null;
    return AppPackageInfo.fromMap(map);
  }

  /// Installs the APK located at [path].
  ///
  /// Only supported on Android.
  Future<bool> installApk(String path) async {
    if (!Curiosity.isAndroid) return false;
    return await _channel.invokeMethod<bool>('installApk', path) ?? false;
  }
}
