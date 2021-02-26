import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_curiosity/constant/constant.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class NetworkPlatform extends PlatformInterface {
  /// Constructs a NetworkPlatform.
  NetworkPlatform() : super(token: _token);

  static final Object _token = Object();

  static NetworkPlatform _instance = _NetworkChannel();

  /// The default instance of [NetworkPlatform] to use.
  ///
  /// Defaults to [MethodChannelNetwork].
  static NetworkPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [NetworkPlatform] when they register themselves.
  static set instance(NetworkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Checks the connection status of the device.
  Future<NetworkResult> checkNetwork() =>
      throw UnimplementedError('checkNetwork() has not been implemented.');

  /// Returns a Stream of NetworkResults changes.
  Stream<NetworkResult> get onChanged => throw UnimplementedError(
      'get onNetworkChanged has not been implemented.');

  /// Obtains the wifi name (SSID) of the connected network
  Future<String> getWifiName() =>
      throw UnimplementedError('getWifiName() has not been implemented.');

  /// Obtains the wifi BSSID of the connected network.
  Future<String> getWifiBSSID() =>
      throw UnimplementedError('getWifiBSSID() has not been implemented.');

  /// Obtains the IP address of the connected wifi network
  Future<String> getWifiIP() =>
      throw UnimplementedError('getWifiIP() has not been implemented.');

  /// Request to authorize the location service (Only on iOS).
  Future<LocationAuthorizeStatus> requestLocationServiceAuthorization(
      {bool requestAlwaysLocationUsage = false}) {
    throw UnimplementedError(
        'requestLocationServiceAuthorization() has not been implemented.');
  }

  /// Get the current location service authorization (Only on iOS).
  Future<LocationAuthorizeStatus> getLocationServiceAuthorization() {
    throw UnimplementedError(
        'getLocationServiceAuthorization() has not been implemented.');
  }
}

/// An implementation of [NetworkPlatform] that uses method channels.
class _NetworkChannel extends NetworkPlatform {
  Stream<NetworkResult> _onChanged;

  /// Fires whenever the network state changes.
  @override
  Stream<NetworkResult> get onChanged {
    const EventChannel eventChannel = EventChannel(connectivityEvent);
    _onChanged ??= eventChannel.receiveBroadcastStream().map((dynamic result) {
      return result != null ? result.toString() : '';
    }).map(getType);
    return _onChanged;
  }

  @override
  Future<NetworkResult> checkNetwork() async {
    final String checkResult =
        await curiosityChannel.invokeMethod<String>('checkNetwork') ?? '';
    return getType(checkResult);
  }

  @override
  Future<String> getWifiName() async {
    String wifiName = await curiosityChannel.invokeMethod<String>('wifiName');
    if (wifiName == '<unknown ssid>') wifiName = null;
    return wifiName;
  }

  @override
  Future<String> getWifiBSSID() =>
      curiosityChannel.invokeMethod<String>('wifiBSSID');

  @override
  Future<String> getWifiIP() =>
      curiosityChannel.invokeMethod<String>('wifiIPAddress');

  @override
  Future<LocationAuthorizeStatus> requestLocationServiceAuthorization({
    bool requestAlwaysLocationUsage = false,
  }) async {
    final String requestLocationServiceResult = await curiosityChannel
            .invokeMethod<String>('requestLocationServiceAuthorization',
                <bool>[requestAlwaysLocationUsage]) ??
        '';
    return _parseLocationAuthorizeStatus(requestLocationServiceResult);
  }

  @override
  Future<LocationAuthorizeStatus> getLocationServiceAuthorization() async {
    final String getLocationServiceResult = await curiosityChannel
            .invokeMethod<String>('getLocationServiceAuthorization') ??
        '';
    return _parseLocationAuthorizeStatus(getLocationServiceResult);
  }

  /// Convert a String to a LocationAuthorizeStatus value.
  LocationAuthorizeStatus _parseLocationAuthorizeStatus(String result) {
    switch (result) {
      case 'notDetermined':
        return LocationAuthorizeStatus.notDetermined;
      case 'restricted':
        return LocationAuthorizeStatus.restricted;
      case 'denied':
        return LocationAuthorizeStatus.denied;
      case 'authorizedAlways':
        return LocationAuthorizeStatus.authorizedAlways;
      case 'authorizedWhenInUse':
        return LocationAuthorizeStatus.authorizedWhenInUse;
      default:
        return LocationAuthorizeStatus.unknown;
    }
  }

  /// Convert a String to a NetworkResult value.
  NetworkResult getType(String state) {
    switch (state) {
      case 'wifi':
        return NetworkResult.wifi;
      case 'mobile':
        return NetworkResult.mobile;
      case 'none':
      default:
        return NetworkResult.none;
    }
  }
}

class Network {
  factory Network() {
    _singleton ??= Network._();
    return _singleton;
  }

  Network._();

  static Network _singleton;

  static NetworkPlatform get _platform => NetworkPlatform.instance;

  Stream<NetworkResult> get onChanged => _platform.onChanged;

  Future<NetworkResult> get checkNetwork => _platform.checkNetwork();
}
