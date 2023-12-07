part of '../flutter_curiosity.dart';

abstract class _PackageInfo {
  _PackageInfo(
      {this.packageName, this.version, this.buildNumber, this.appName});

  final String? packageName;
  final String? version;
  final String? buildNumber;
  final String? appName;
}

class PackageSelfInfo extends _PackageInfo {
  PackageSelfInfo(
      {this.firstInstallTime,
      this.lastUpdateTime,
      this.minimumOSVersion,
      this.platformVersion,
      this.sdkBuild,
      this.platformName,
      super.packageName,
      super.version,
      super.buildNumber,
      super.appName});

  factory PackageSelfInfo.fromJson(Map<String, dynamic> json) =>
      PackageSelfInfo(

          /// android ios macos
          version: json['version'] as String?,
          buildNumber: json['buildNumber'] as String?,
          packageName: json['packageName'] as String?,
          appName: json['appName'] as String?,

          /// only Android
          firstInstallTime: json['firstInstallTime'] as int?,
          lastUpdateTime: json['lastUpdateTime'] as int?,

          /// only ios
          minimumOSVersion: json['minimumOSVersion'] as String?,
          platformVersion: json['platformVersion'] as String?,
          sdkBuild: json['sdkBuild'] as String?,
          platformName: json['platformName'] as String?);

  /// only Android
  final int? firstInstallTime;
  final int? lastUpdateTime;

  /// only ios
  final String? minimumOSVersion;
  final String? platformVersion;
  final String? sdkBuild;
  final String? platformName;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'version': version,
        'packageName': packageName,
        'appName': appName,
        'buildNumber': buildNumber,
        'lastUpdateTime': lastUpdateTime,
        'firstInstallTime': firstInstallTime,
        'minimumOSVersion': minimumOSVersion,
        'platformVersion': platformVersion,
        'sdkBuild': sdkBuild,
        'platformName': platformName,
      };
}

class AppPackageInfo extends _PackageInfo {
  AppPackageInfo(
      {this.isSystemApp,
      this.lastUpdateTime,
      super.packageName,
      super.version,
      super.buildNumber,
      super.appName});

  factory AppPackageInfo.fromJson(Map<dynamic, dynamic> json) => AppPackageInfo(
      isSystemApp: json['isSystemApp'] as bool?,
      appName: json['appName'] as String?,
      lastUpdateTime: json['lastUpdateTime'] as int?,
      buildNumber: json['buildNumber'] as String?,
      version: json['version'] as String?,
      packageName: json['packageName'] as String?);

  final bool? isSystemApp;
  final int? lastUpdateTime;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'isSystemApp': isSystemApp,
        'appName': appName,
        'lastUpdateTime': lastUpdateTime,
        'buildNumber': buildNumber,
        'version': version,
        'packageName': packageName
      };
}

class AndroidActivityResult {
  AndroidActivityResult.formJson(Map<dynamic, dynamic> json) {
    requestCode = json['requestCode'] as int;
    resultCode = json['resultCode'] as int;
    data = json['data'] as dynamic;
    extras = json['extras'] as dynamic;
  }

  late int requestCode;
  late int resultCode;
  dynamic data;
  dynamic extras;
}
