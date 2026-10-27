part of '../flutter_curiosity.dart';

/// Information about an installed app package.
class AppPackageInfo {
  /// Creates app package info.
  const AppPackageInfo({
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.appName,
    required this.isSystemApp,
    required this.lastUpdateTime,
    required this.firstInstallTime,
  });

  /// Creates app package info from a map received from Android.
  factory AppPackageInfo.fromMap(Map<dynamic, dynamic> json) => AppPackageInfo(
    packageName: json['packageName'] as String? ?? '',
    version: json['version'] as String? ?? '',
    buildNumber: json['buildNumber'] as String? ?? '',
    appName: json['appName'] as String? ?? '',
    isSystemApp: json['isSystemApp'] as bool? ?? false,
    lastUpdateTime: json['lastUpdateTime'] as int? ?? 0,
    firstInstallTime: json['firstInstallTime'] as int? ?? 0,
  );

  /// The package name.
  final String packageName;

  /// The version name.
  final String version;

  /// The version code.
  final String buildNumber;

  /// The app label.
  final String appName;

  /// Whether the app is a system app.
  final bool isSystemApp;

  /// The last update time in milliseconds since epoch.
  final int lastUpdateTime;

  /// The first install time in milliseconds since epoch.
  final int firstInstallTime;

  /// Converts this info to a map.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'packageName': packageName,
    'version': version,
    'buildNumber': buildNumber,
    'appName': appName,
    'isSystemApp': isSystemApp,
    'lastUpdateTime': lastUpdateTime,
    'firstInstallTime': firstInstallTime,
  };
}
