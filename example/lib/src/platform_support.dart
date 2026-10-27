import 'package:flutter_curiosity/flutter_curiosity.dart';

/// 示例中展示的平台。
enum DemoPlatform {
  android('Android'),
  ios('iOS'),
  macOS('macOS'),
  harmonyOS('HarmonyOS'),
  web('Web'),
  windows('Windows'),
  linux('Linux');

  const DemoPlatform(this.label);

  /// 平台全称。
  final String label;

  /// 当前运行平台。
  static DemoPlatform? get current {
    if (Curiosity.isHarmonyOS) return harmonyOS;
    if (Curiosity.isAndroid) return android;
    if (Curiosity.isIOS) return ios;
    if (Curiosity.isMacOS) return macOS;
    if (Curiosity.isWeb) return web;
    if (Curiosity.isWindows) return windows;
    if (Curiosity.isLinux) return linux;
    return null;
  }
}

/// 各功能支持的平台集合。
abstract final class PlatformSets {
  /// 全部平台。
  static const Set<DemoPlatform> all = <DemoPlatform>{
    DemoPlatform.android,
    DemoPlatform.ios,
    DemoPlatform.macOS,
    DemoPlatform.harmonyOS,
    DemoPlatform.web,
    DemoPlatform.windows,
    DemoPlatform.linux,
  };

  /// 支持键盘状态的平台。
  static const Set<DemoPlatform> keyboard = <DemoPlatform>{
    DemoPlatform.android,
    DemoPlatform.ios,
    DemoPlatform.harmonyOS,
    DemoPlatform.web,
  };

  /// 支持 GPS 状态的平台。
  static const Set<DemoPlatform> gps = <DemoPlatform>{
    DemoPlatform.android,
    DemoPlatform.ios,
    DemoPlatform.macOS,
    DemoPlatform.harmonyOS,
    DemoPlatform.web,
  };

  /// Android 专属能力。
  static const Set<DemoPlatform> androidOnly = <DemoPlatform>{DemoPlatform.android};

  /// 支持保存图片字节的平台。
  static const Set<DemoPlatform> galleryBytes = <DemoPlatform>{
    DemoPlatform.android,
    DemoPlatform.ios,
    DemoPlatform.macOS,
    DemoPlatform.harmonyOS,
    DemoPlatform.web,
    DemoPlatform.windows,
    DemoPlatform.linux,
  };

  /// 支持保存文件路径的平台。
  static const Set<DemoPlatform> galleryFile = <DemoPlatform>{
    DemoPlatform.android,
    DemoPlatform.ios,
    DemoPlatform.macOS,
    DemoPlatform.harmonyOS,
    DemoPlatform.windows,
    DemoPlatform.linux,
  };

  /// 返回支持平台的中文描述。
  static String describe(Set<DemoPlatform> platforms) {
    if (platforms.length == all.length) return '全部平台';
    return platforms.map((DemoPlatform platform) => platform.label).join('、');
  }
}
