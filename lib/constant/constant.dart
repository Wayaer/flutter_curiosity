import 'package:flutter/services.dart';

const String curiosity = 'Curiosity';
const String curiosityEvent = 'curiosity/event';
const String scannerEvent = '$curiosity/event/scanner';

const MethodChannel curiosityChannel = MethodChannel(curiosity);

enum ShareType {
  /// android ios
  text,

  /// android ios
  image,

  /// android ios
  images,

  /// ios
  url,
}
enum CameraResolution {
  /// android QUALITY_QVGA   ios 288*352
  low,

  /// android 480*640  ios 480*640
  medium,

  /// android 720*1280  ios 720*1280
  high,

  /// android 1080*1920  ios 1080*1920
  veryHigh,

  /// android 2160*3840  ios 2160*3840
  ultraHigh,

  /// android QUALITY_HIGH  ios 最大
  Max
}
enum CameraLensFacing {
  /// 后置
  back,

  /// 前置
  front,

  /// 其他的
  external
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

/// Connection status check result.
enum NetworkResult {
  /// WiFi: Device connected via Wi-Fi
  wifi,

  /// Mobile: Device connected to cellular network
  mobile,

  /// None: Device not connected to any network
  none
}
