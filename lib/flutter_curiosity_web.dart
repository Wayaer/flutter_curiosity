import 'package:flutter_curiosity/tools/internal.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class CuriosityPlugin extends PlatformInterface {
  static void registerWith(Registrar registrar) {
    log('flutter_curiosity 未支持web平台');
  }
}

abstract class CuriosityPlatform extends PlatformInterface {}
