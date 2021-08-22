import 'package:flutter/services.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/src/internal.dart';

typedef EventHandlerActivityResult = void Function(
    AndroidActivityResult result);

typedef EventHandlerRequestPermissionsResult = void Function(
    AndroidRequestPermissionsResult result);

typedef KeyboardStatus = void Function(bool visibility);

class NativeTools {
  factory NativeTools() => _getInstance();

  NativeTools._internal();

  static NativeTools get instance => _getInstance();

  static NativeTools? _instance;

  static NativeTools _getInstance() {
    _instance ??= NativeTools._internal();
    return _instance!;
  }

  /// 检测是否允许安装apk
  /// only supports Android
  Future<bool> checkCanInstallApp([bool openSetting = true]) async {
    if (!isAndroid) return false;
    final bool? state =
        await channel.invokeMethod<bool?>('checkCanInstallApp', openSetting);
    return state ?? false;
  }

  /// 安装apk  仅支持android
  /// Installing APK only supports Android
  Future<bool?> installApp(String apkPath, {bool openSetting = true}) async {
    if (!isAndroid) return null;
    final bool state = await checkCanInstallApp(openSetting);
    if (!state) return state;
    return await channel.invokeMethod<bool?>('installApp', apkPath);
  }

  /// android  packageName，安装多个应用商店时会弹窗选择, marketPackageName 指定打开应用市场的包名
  Future<bool> openAndroidAppMarket(String packageName,
      {String? marketPackageName}) async {
    if (!isAndroid) return false;
    bool? state = false;
    try {
      if (marketPackageName != null) {
        state = await hasInstallAppWithAndroid(marketPackageName);
        if (!state) return state;
      }
      state = await channel.invokeMethod<bool>(
          'openAppMarket', <String, String>{
        'packageName': packageName,
        'marketPackageName': marketPackageName ?? ''
      });
    } catch (e) {
      state = false;
    }
    return state ?? false;
  }

  /// 是否安装某个app
  /// Android packageName 对应包名
  Future<bool> hasInstallAppWithAndroid(String packageName) async {
    if (!isAndroid) return false;
    final bool? data =
        await channel.invokeMethod<bool?>('isInstallApp', packageName);
    return data ?? false;
  }

  /// 判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
  Future<bool> get gpsStatus async {
    if (!supportPlatform) return false;
    final bool? state = await channel.invokeMethod('getGPSStatus');
    return state ?? false;
  }

  /// 跳转到系统设置页面
  /// settingType 仅对android 有效
  Future<bool> openSystemSetting(
      {AndroidSettingPath? path, MacOSSettingPath? macPath}) async {
    if (supportPlatform) {
      String? data;
      if (isAndroid) {
        final List<String> type =
            (path ?? AndroidSettingPath.setting).toString().split('.');
        data = type[1];
      } else if (isMacOS) {
        data = macOSSettingPathToString(
            macPath ?? MacOSSettingPath.accessibilityMain);
      }
      final bool? state = await channel.invokeMethod('openSystemSetting', data);
      return state ?? false;
    }
    return false;
  }

  /// Exit app
  void exitApp() {
    if (!supportPlatform) return;
    channel.invokeMethod<dynamic>('exitApp');
  }

  /// get Android/IOS/MacOS Device Info
  Future<DeviceInfoModel?> get deviceInfo async {
    if (!supportPlatform) return null;
    final Map<String, dynamic>? map =
        await channel.invokeMapMethod<String, dynamic>('getDeviceInfo');
    if (map != null) return DeviceInfoModel.fromJson(map);
    return null;
  }

  /// get Android/IOS/MacOS path
  Future<AppPathModel?> get appPath async {
    if (!supportPlatform) return null;
    final Map<String, dynamic>? map =
        await channel.invokeMapMethod<String, dynamic>('getAppPath');
    if (map != null) return AppPathModel.fromJson(map);
    return null;
  }

  /// get Android/IOS/MacOS info
  Future<AppInfoModel?> get appInfo async {
    if (!supportPlatform) return null;
    final Map<String, dynamic>? map =
        await channel.invokeMapMethod<String, dynamic>('getAppInfo');
    if (map != null) return AppInfoModel.fromJson(map);
    return null;
  }

  /// get Android  installed apps
  Future<List<AppsModel>> get installedApp async {
    if (!isAndroid) return <AppsModel>[];
    final List<Map<dynamic, dynamic>>? appList = await channel
        .invokeListMethod<Map<dynamic, dynamic>>('getInstalledApp');
    final List<AppsModel> list = <AppsModel>[];
    if (appList != null && appList is List) {
      for (final dynamic data in appList) {
        list.add(AppsModel.fromJson(data as Map<dynamic, dynamic>));
      }
    }
    return list;
  }

  /// android ios  键盘状态监听
  void keyboardListener(KeyboardStatus keyboardStatus) {
    if (!supportPlatformMobile) return;
    channel.setMethodCallHandler((MethodCall call) async {
      if (call.method != 'keyboardStatus') return;
      return keyboardStatus(call.arguments as bool);
    });
  }

  /// android
  /// onActivityResult 监听
  /// onRequestPermissionsResult 监听
  Future<void> onResultListener({
    EventHandlerActivityResult? activityResult,
    EventHandlerRequestPermissionsResult? requestPermissionsResult,
  }) async {
    if (!supportPlatformMobile) return;
    if (isAndroid) {
      if (activityResult != null)
        await channel.invokeMethod<dynamic>('onActivityResult');

      if (requestPermissionsResult != null)
        await channel.invokeMethod<dynamic>('onRequestPermissionsResult');
    }
    channel.setMethodCallHandler((MethodCall call) async {
      final Map<dynamic, dynamic> argument =
          call.arguments as Map<dynamic, dynamic>;
      switch (call.method) {
        case 'onActivityResult':
          if (activityResult != null)
            activityResult(AndroidActivityResult.formJson(argument));
          break;
        case 'onRequestPermissionsResult':
          if (requestPermissionsResult != null)
            requestPermissionsResult(
                AndroidRequestPermissionsResult.formJson(argument));
          break;
      }
    });
  }
}

/// Android 系统设置
enum AndroidSettingPath {
  /// wifi
  wifi,

  /// wifi ip
  wifiIp,

  /// 定位
  location,

  /// 密码安全
  passwordSecurity,

  /// 蓝牙
  bluetooth,

  /// 移动数据
  cellularNetwork,

  /// 语言和时间
  time,

  /// 显示和亮度
  displayBrightness,

  /// 通知
  notification,

  /// 声音和振动
  soundVibration,

  /// 内部存储
  internalStorage,

  /// 电量管理
  battery,

  /// 语言设置
  localeLanguage,

  /// nfc
  nfc,

  /// setting
  setting,

  /// 手机状态信息的界面
  deviceInfo,

  /// 开发者选项设置
  applicationDevelopment,

  /// 选取运营商的界面
  networkOperator,

  /// 添加账户界面
  addAccount,

  /// 双卡和移动网络设置界面
  dataRoaming,

  /// 更多连接方式设置界面
  airplaneMode
}

enum MacOSSettingPath {
  /// Accessibility 面板相关 ///
  /// 辅助面板根目录
  accessibilityMain,

  /// 辅助面板-显示
  accessibilityDisplay,

  /// 辅助面板-缩放
  accessibilityZoom,

  /// 辅助面板-显示
  accessibilityVoiceOver,

  /// 辅助面板-旁白
  accessibilityDescriptions,

  /// 辅助面板-描述
  accessibilityCaptions,

  /// 辅助面板-音频
  accessibilityAudio,

  /// 辅助面板-键盘
  accessibilityKeyboard,

  /// 辅助面板-指针控制
  accessibilityMouseTrackpad,

  /// 安全&隐私相关
  /// 安全&隐私相关-根目录
  securityMain,

  /// 安全&隐私相关-通用
  securityGeneral,

  /// 安全&隐私相关-文件保险箱
  securityFileVault,

  /// 安全&隐私相关-防火墙
  securityFirewall,

  /// 安全&隐私相关-高级
  securityAdvanced,

  /// 安全&隐私相关-隐私
  securityPrivacy,

  /// 安全&隐私相关-辅助功能
  securityPrivacyAccessibility,

  /// 安全&隐私相关-完全磁盘访问权限
  securityPrivacyAssistive,

  /// 文件和文件夹
  securityPrivacyAllFiles,

  /// 安全&隐私相关-定位
  securityPrivacyLocationServices,

  /// 安全&隐私相关-通讯录
  securityPrivacyContacts,

  /// 安全&隐私相关-分析与改进
  securityPrivacyDiagnosticsUsage,

  /// 安全&隐私相关-日历
  securityPrivacyCalendars,

  /// 安全&隐私相关-提醒事项
  securityPrivacyReminders,

  /// 键盘-听写
  speechDictation,

  /// 键盘-siri
  speechTextToSpeech,

  /// 共享
  /// 共享-更目录
  sharingMain,

  /// 共享-屏幕共享
  sharingScreenSharing,

  /// 共享-文件共享
  sharingFileSharing,

  /// 共享-打印机共享
  sharingPrinterSharing,

  /// 共享-远程登录
  sharingRemoteLogin,

  /// 共享-远程管理
  sharingRemoteManagement,

  /// 共享-远程apple事件
  sharingRemoteAppleEvents,

  /// 共享-互联网共享
  sharingInternetSharing,

  /// 共享-蓝牙共享
  sharingBluetoothSharing,
}
