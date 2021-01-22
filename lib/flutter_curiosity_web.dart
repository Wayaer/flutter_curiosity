import 'package:flutter_curiosity/tools/internal.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class CuriosityPlugin extends PlatformInterface {
  static void registerWith(Registrar registrar) {
    log('未支持web平台');
  }
}

abstract class CuriosityPlatform extends PlatformInterface {}
