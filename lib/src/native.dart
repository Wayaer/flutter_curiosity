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

  PackageInfoPlus? _packageInfo;

  Future<PackageInfoPlus?> get packageInfo async =>
      _packageInfo ??= await getPackageInfo();

  /// get Android/IOS/MacOS info
  Future<PackageInfoPlus?> getPackageInfo() async {
    if (!_supportPlatform) return null;
    final Map<String, dynamic>? map =
        await _channel.invokeMapMethod<String, dynamic>('getPackageInfo');
    if (map != null) return PackageInfoPlus.fromJson(map);
    return null;
  }

  /// get Android  installed apps
  Future<List<AppPackageInfo>> get getInstalledApps async {
    if (!isAndroid) return [];
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
    if (!isAndroid) return false;
    final result = await _channel.invokeMethod<bool?>('installApk', apkPath);
    return result ?? false;
  }
}

abstract class _PackageInfo {
  _PackageInfo(
      {this.packageName, this.version, this.buildNumber, this.appName});

  final String? packageName;
  final String? version;
  final String? buildNumber;
  final String? appName;
}

class PackageInfoPlus extends _PackageInfo {
  PackageInfoPlus(
      {this.firstInstallTime,
      this.lastUpdateTime,
      this.minimumOSVersion,
      this.platformVersion,
      this.sdkBuild,
      this.platformName,
      super.packageName,
      super.version,
      super.buildNumber,
      super.appName});

  factory PackageInfoPlus.fromJson(Map<String, dynamic> json) =>
      PackageInfoPlus(

          /// android ios macos
          version: json['version'] as String?,
          buildNumber: json['buildNumber'] as String?,
          packageName: json['packageName'] as String?,
          appName: json['appName'] as String?,

          /// only Android
          firstInstallTime: json['firstInstallTime'] as int?,
          lastUpdateTime: json['lastUpdateTime'] as int?,

          /// only ios
          minimumOSVersion: json['minimumOSVersion'] as String?,
          platformVersion: json['platformVersion'] as String?,
          sdkBuild: json['sdkBuild'] as String?,
          platformName: json['platformName'] as String?);

  /// only Android
  final int? firstInstallTime;
  final int? lastUpdateTime;

  /// only ios
  final String? minimumOSVersion;
  final String? platformVersion;
  final String? sdkBuild;
  final String? platformName;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'version': version,
        'packageName': packageName,
        'appName': appName,
        'buildNumber': buildNumber,
        'lastUpdateTime': lastUpdateTime,
        'firstInstallTime': firstInstallTime,
        'minimumOSVersion': minimumOSVersion,
        'platformVersion': platformVersion,
        'sdkBuild': sdkBuild,
        'platformName': platformName,
      };
}

class AppPackageInfo extends _PackageInfo {
  AppPackageInfo(
      {this.isSystemApp,
      this.lastUpdateTime,
      super.packageName,
      super.version,
      super.buildNumber,
      super.appName});

  factory AppPackageInfo.fromJson(Map<dynamic, dynamic> json) => AppPackageInfo(
      isSystemApp: json['isSystemApp'] as bool?,
      appName: json['appName'] as String?,
      lastUpdateTime: json['lastUpdateTime'] as int?,
      buildNumber: json['buildNumber'] as String?,
      version: json['version'] as String?,
      packageName: json['packageName'] as String?);

  final bool? isSystemApp;
  final int? lastUpdateTime;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'isSystemApp': isSystemApp,
        'appName': appName,
        'lastUpdateTime': lastUpdateTime,
        'buildNumber': buildNumber,
        'version': version,
        'packageName': packageName
      };
}

class AndroidActivityResult {
  AndroidActivityResult.formJson(Map<dynamic, dynamic> json) {
    requestCode = json['requestCode'] as int;
    resultCode = json['resultCode'] as int;
    data = json['data'] as dynamic;
    extras = json['extras'] as dynamic;
  }

  late int requestCode;
  late int resultCode;
  dynamic data;
  dynamic extras;
}
