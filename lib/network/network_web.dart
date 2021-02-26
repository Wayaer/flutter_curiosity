import 'dart:async';
import 'dart:html' as html show window, NetworkInformation;
import 'dart:html';
import 'dart:js';
import 'dart:js_util';

import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/flutter_curiosity_web.dart';

import 'package:flutter/foundation.dart';

/// The web implementation of the NetworkPlatform of the Network plugin.
class NetworkInformationApiNetworkPlugin extends CuriosityPlugin {
  /// The constructor of the plugin.
  NetworkInformationApiNetworkPlugin()
      : this.withConnection(html.window.navigator.connection);

  /// Creates the plugin, with an override of the NetworkInformation object.
  @visibleForTesting
  NetworkInformationApiNetworkPlugin.withConnection(
      html.NetworkInformation connection)
      : _networkInformation = connection;

  final html.NetworkInformation _networkInformation;

  /// A check to determine if this version of the plugin can be used.
  static bool get isSupported => html.window.navigator.connection != null;

  /// Checks the connection status of the device.
  @override
  Future<NetworkResult> checkNetwork() async =>
      networkInformationToNetworkResult(_networkInformation);

  StreamController<NetworkResult> _networkResultStreamController;
  Stream<NetworkResult> _networkResultStream;

  /// Returns a Stream of NetworkResults changes.
  @override
  Stream<NetworkResult> get onChanged {
    if (_networkResultStreamController == null) {
      _networkResultStreamController = StreamController<NetworkResult>();
      setProperty(_networkInformation, 'onchange', allowInterop((dynamic _) {
        _networkResultStreamController
            .add(networkInformationToNetworkResult(_networkInformation));
      }));
      // _networkInformation.onChange.listen((_) {
      //   _networkResult
      //       .add(networkInformationToNetworkResult(_networkInformation));
      // });
      // Once we can detect when to *cancel* a subscription to the _networkInformation
      // onChange Stream upon hot restart.
      // https://github.com/dart-lang/sdk/issues/42679
      _networkResultStream =
          _networkResultStreamController.stream.asBroadcastStream();
    }
    return _networkResultStream;
  }

  /// Converts an incoming NetworkInformation object into the correct NetworkResult.
  NetworkResult networkInformationToNetworkResult(
    html.NetworkInformation info,
  ) {
    if (info == null) {
      return NetworkResult.none;
    }
    if (info.downlink == 0 && info.rtt == 0) {
      return NetworkResult.none;
    }
    if (info.effectiveType != null) {
      return effectiveTypeToNetworkResult(info.effectiveType);
    }
    if (info.type != null) {
      return typeToNetworkResult(info.type);
    }
    return NetworkResult.none;
  }

  NetworkResult effectiveTypeToNetworkResult(String effectiveType) {
    // Possible values:
    /*'2g'|'3g'|'4g'|'slow-2g'*/
    switch (effectiveType) {
      case 'slow-2g':
      case '2g':
      case '3g':
        return NetworkResult.mobile;
      default:
        return NetworkResult.wifi;
    }
  }

  NetworkResult typeToNetworkResult(String type) {
    // Possible values:
    /*'bluetooth'|'cellular'|'ethernet'|'mixed'|'none'|'other'|'unknown'|'wifi'|'wimax'*/
    switch (type) {
      case 'none':
        return NetworkResult.none;
      case 'bluetooth':
      case 'cellular':
      case 'mixed':
      case 'other':
      case 'unknown':
        return NetworkResult.mobile;
      default:
        return NetworkResult.wifi;
    }
  }
}

/// The web implementation of the NetworkPlatform of the Network plugin.
class DartHtmlNetworkPlugin extends CuriosityPlugin {
  /// Checks the connection status of the device.
  @override
  Future<NetworkResult> checkNetwork() async {
    return html.window.navigator.onLine
        ? NetworkResult.wifi
        : NetworkResult.none;
  }

  StreamController<NetworkResult> _connectivityResult;

  /// Returns a Stream of NetworkResults changes.
  @override
  Stream<NetworkResult> get onChanged {
    if (_connectivityResult == null) {
      _connectivityResult = StreamController<NetworkResult>();
      // Fallback to dart:html window.onOnline / window.onOffline
      html.window.onOnline.listen((Event event) {
        _connectivityResult.add(NetworkResult.wifi);
      });
      html.window.onOffline.listen((Event event) {
        _connectivityResult.add(NetworkResult.none);
      });
    }
    return _connectivityResult.stream;
  }
}
