import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/network/network_web.dart';
import 'package:flutter_curiosity/tools/internal.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter/services.dart';

// class CuriosityPlugin extends PlatformInterface {
//   static void registerWith(Registrar registrar) {
//     log('flutter_curiosity 未支持web平台');
//   }
// }

/// The web implementation of the NetworkPlatform of the Connectivity plugin.
class CuriosityPlugin extends NetworkPlatform {
  /// Factory method that initializes the network plugin platform with an instance
  /// of the plugin for the web.
  static void registerWith(Registrar registrar) {
    if (NetworkInformationApiNetworkPlugin.isSupported) {
      NetworkPlatform.instance = NetworkInformationApiNetworkPlugin();
    } else {
      NetworkPlatform.instance = DartHtmlNetworkPlugin();
    }
  }

  // The following are completely unsupported methods on the web platform.

  // Creates an "unsupported_operation" PlatformException for a given `method` name.
  Object _unsupported(String method) {
    return PlatformException(
      code: 'UNSUPPORTED_OPERATION',
      message: '$method() is not supported on the web platform.',
    );
  }

  /// Obtains the wifi name (SSID) of the connected network
  @override
  Future<String> getWifiName() {
    throw _unsupported('getWifiName');
  }

  /// Obtains the wifi BSSID of the connected network.
  @override
  Future<String> getWifiBSSID() {
    throw _unsupported('getWifiBSSID');
  }

  /// Obtains the IP address of the connected wifi network
  @override
  Future<String> getWifiIP() {
    throw _unsupported('getWifiIP');
  }

  /// Request to authorize the location service (Only on iOS).
  @override
  Future<LocationAuthorizeStatus> requestLocationServiceAuthorization(
      {bool requestAlwaysLocationUsage = false}) {
    throw _unsupported('requestLocationServiceAuthorization');
  }

  /// Get the current location service authorization (Only on iOS).
  @override
  Future<LocationAuthorizeStatus> getLocationServiceAuthorization() {
    throw _unsupported('getLocationServiceAuthorization');
  }
}
