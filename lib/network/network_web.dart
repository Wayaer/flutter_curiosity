import 'dart:async';
import 'dart:html' as html show window, NetworkInformation;
import 'dart:html';
import 'dart:js';
import 'dart:js_util';

import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/flutter_curiosity_web.dart';

import 'package:flutter/foundation.dart';

class NetworkInformationPlugin extends NetworkPlatform {
  NetworkInformationPlugin()
      : this.withConnection(html.window.navigator.connection);

  @visibleForTesting
  NetworkInformationPlugin.withConnection(html.NetworkInformation connection)
      : _networkInformation = connection;

  final html.NetworkInformation _networkInformation;

  @override
  Future<NetworkResult> checkNetwork() async =>
      networkInformationToNetworkResult(_networkInformation);

  StreamController<NetworkResult> _networkResultStreamController;
  Stream<NetworkResult> _networkResultStream;

  @override
  Stream<NetworkResult> get onChanged {
    if (_networkResultStreamController == null) {
      _networkResultStreamController = StreamController<NetworkResult>();
      setProperty(_networkInformation, 'onchange', allowInterop((dynamic _) {
        _networkResultStreamController
            .add(networkInformationToNetworkResult(_networkInformation));
      }));
      _networkResultStream =
          _networkResultStreamController.stream.asBroadcastStream();
    }
    return _networkResultStream;
  }

  NetworkResult networkInformationToNetworkResult(
      html.NetworkInformation info) {
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
class DartHtmlNetworkPlugin extends NetworkPlatform {
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
