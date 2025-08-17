part of '../flutter_curiosity.dart';

class AppPackageInfo {
  AppPackageInfo(
      {required this.packageName,
      required this.version,
      required this.buildNumber,
      required this.appName,
      required this.isSystemApp,
      required this.lastUpdateTime,
      required this.firstInstallTime});

  factory AppPackageInfo.fromMap(Map<dynamic, dynamic> json) => AppPackageInfo(
      isSystemApp: json['isSystemApp'] as bool?,
      appName: json['appName'] as String?,
      lastUpdateTime: json['lastUpdateTime'] as int?,
      firstInstallTime: json['firstInstallTime'] as int?,
      buildNumber: json['buildNumber'] as String?,
      version: json['version'] as String?,
      packageName: json['packageName'] as String?);

  final String? packageName;
  final String? version;
  final String? buildNumber;
  final String? appName;
  final bool? isSystemApp;
  final int? lastUpdateTime;
  final int? firstInstallTime;

  Map<String, dynamic> toMap() => {
        'version': version,
        'packageName': packageName,
        'appName': appName,
        'buildNumber': buildNumber,
        'isSystemApp': isSystemApp,
        'lastUpdateTime': lastUpdateTime,
        'firstInstallTime': firstInstallTime,
      };
}
