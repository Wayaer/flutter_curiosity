import 'dart:html' as html show window;

import 'package:flutter/services.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/network/network_web.dart';
import 'package:flutter_curiosity/tools/internal.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class CuriosityPlugin extends PlatformInterface {
  static void registerWith(Registrar registrar) {
    log('flutter_curiosity 未支持web平台');
  }
}

bool get _isSupported => html.window.navigator.connection != null;

class NetworkPlugin extends NetworkPlatform {
  static void registerWith(Registrar registrar) {
    NetworkPlatform.instance =
        _isSupported ? NetworkInformationPlugin() : DartHtmlNetworkPlugin();
  }

  Object _unsupported(String method) {
    return PlatformException(
      code: 'UNSUPPORTED_OPERATION',
      message: '$method() is not supported on the web platform.',
    );
  }

  @override
  Future<String> getWifiName() {
    throw _unsupported('getWifiName');
  }

  @override
  Future<String> getWifiBSSID() {
    throw _unsupported('getWifiBSSID');
  }

  @override
  Future<String> getWifiIP() {
    throw _unsupported('getWifiIP');
  }

  @override
  Future<LocationAuthorizeStatus> requestLocationServiceAuthorization(
      {bool requestAlwaysLocationUsage = false}) {
    throw _unsupported('requestLocationServiceAuthorization');
  }

  @override
  Future<LocationAuthorizeStatus> getLocationServiceAuthorization() {
    throw _unsupported('getLocationServiceAuthorization');
  }
}
