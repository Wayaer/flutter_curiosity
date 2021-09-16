class AppPathModel {
  AppPathModel.fromJson(Map<String, dynamic> json) {
    ///  android ios
    directoryMusic = json['directoryMusic'] as String?;
    directoryDocuments = json['directoryDocuments'] as String?;
    directoryMovies = json['directoryMovies'] as String?;
    directoryPictures = json['directoryPictures'] as String?;
    directoryAlarms = json['directoryAlarms'] as String?;
    directoryDownloads = json['directoryDownloads'] as String?;

    /// only Android
    cacheDir = json['cacheDir'] as String?;
    filesDir = json['filesDir'] as String?;
    externalCacheDir = json['externalCacheDir'] as String?;
    externalFilesDir = json['externalFilesDir'] as String?;
    externalStorageDirectory = json['externalStorageDirectory'] as String?;
    directoryDCIM = json['directoryDCIM'] as String?;
    directoryNotifications = json['directoryNotifications'] as String?;
    directoryRINGTONES = json['directoryRINGTONES'] as String?;
    directoryPODCASTS = json['directoryPODCASTS'] as String?;

    /// only ios
    applicationSupportDirectory =
        json['applicationSupportDirectory'] as String?;
    applicationDirectory = json['applicationDirectory'] as String?;
    homeDirectory = json['homeDirectory'] as String?;
    documentDirectory = json['documentDirectory'] as String?;
    libraryDirectory = json['libraryDirectory'] as String?;
    cachesDirectory = json['cachesDirectory'] as String?;
    temporaryDirectory = json['temporaryDirectory'] as String?;
  }

  /// android ios
  String? directoryMusic;
  String? directoryDownloads;
  String? directoryMovies;
  String? directoryPictures;
  String? directoryDocuments;

  /// only android
  String? cacheDir;
  String? filesDir;
  String? externalCacheDir;
  String? externalFilesDir;
  String? directoryAlarms;

  String? directoryDCIM;
  String? directoryNotifications;
  String? directoryRINGTONES;
  String? directoryPODCASTS;
  String? externalStorageDirectory;

  /// only ios
  String? applicationDirectory;
  String? applicationSupportDirectory;
  String? homeDirectory;
  String? libraryDirectory;
  String? documentDirectory;
  String? cachesDirectory;
  String? temporaryDirectory;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'directoryMusic': directoryMusic,
        'directoryDownloads': directoryDownloads,
        'directoryDocuments': directoryDocuments,
        'directoryMovies': directoryMovies,
        'directoryPictures': directoryPictures,
        'cacheDir': cacheDir,
        'filesDir': filesDir,
        'externalCacheDir': externalCacheDir,
        'externalFilesDir': externalFilesDir,
        'externalStorageDirectory': externalStorageDirectory,
        'directoryPODCASTS': directoryPODCASTS,
        'directoryAlarms': directoryAlarms,
        'directoryDCIM': directoryDCIM,
        'directoryNotifications': directoryNotifications,
        'directoryRINGTONES': directoryRINGTONES,
        'applicationSupportDirectory': applicationSupportDirectory,
        'applicationDirectory': applicationDirectory,
        'homeDirectory': homeDirectory,
        'documentDirectory': documentDirectory,
        'temporaryDirectory': temporaryDirectory,
        'cachesDirectory': cachesDirectory,
        'libraryDirectory': libraryDirectory
      };
}

class AppInfoModel {
  AppInfoModel.fromJson(Map<String, dynamic> json) {
    /// android ios
    versionName = json['versionName'] as String?;
    versionCode = json['versionCode'] as int?;
    packageName = json['packageName'] as String?;
    appName = json['appName'] as String?;
    statusBarHeight = json['statusBarHeight'] as double?;

    /// only Android
    firstInstallTime = json['firstInstallTime'] as int?;
    lastUpdateTime = json['lastUpdateTime'] as int?;
    navigationBarHeight = json['navigationBarHeight'] as double?;

    /// only ios
    minimumOSVersion = json['minimumOSVersion'] as String?;
    platformVersion = json['platformVersion'] as String?;
    sdkBuild = json['sdkBuild'] as String?;
    statusBarWidth = json['statusBarWidth'] as double?;
    platformName = json['platformName'] as String?;
  }

  String? packageName;
  String? versionName;
  int? versionCode;
  String? appName;
  double? statusBarHeight;

  /// only Android
  int? firstInstallTime;
  int? lastUpdateTime;
  double? navigationBarHeight;

  /// only ios
  String? minimumOSVersion;
  String? platformVersion;
  String? sdkBuild;
  double? statusBarWidth;
  String? platformName;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'versionName': versionName,
        'packageName': packageName,
        'appName': appName,
        'versionCode': versionCode,
        'statusBarHeight': statusBarHeight,
        'lastUpdateTime': lastUpdateTime,
        'firstInstallTime': firstInstallTime,
        'navigationBarHeight': navigationBarHeight,
        'minimumOSVersion': minimumOSVersion,
        'platformVersion': platformVersion,
        'sdkBuild': sdkBuild,
        'statusBarWidth': statusBarWidth,
        'platformName': platformName,
      };
}

class AppsModel {
  AppsModel.fromJson(Map<dynamic, dynamic> json) {
    isSystemApp = json['isSystemApp'] as bool?;
    appName = json['appName'] as String?;
    lastUpdateTime = json['lastUpdateTime'] as int?;
    versionCode = json['versionCode'] as int?;
    versionName = json['versionName'] as String?;
    packageName = json['packageName'] as String?;
  }

  bool? isSystemApp;
  String? appName;
  int? lastUpdateTime;
  int? versionCode;
  String? versionName;
  String? packageName;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'isSystemApp': isSystemApp,
        'appName': appName,
        'lastUpdateTime': lastUpdateTime,
        'versionCode': versionCode,
        'versionName': versionName,
        'packageName': packageName
      };
}

class DeviceInfoModel {
  DeviceInfoModel.fromJson(Map<String, dynamic> json) {
    /// Android and IOS
    model = json['model'] as String?;
    isEmulator = json['isEmulator'] as bool?;

    /// only Android
    product = json['product'] as String?;
    isEmulator = json['isEmulator'] as bool?;
    display = json['display'] as String?;
    type = json['type'] as String?;
    version = json['version'] != null
        ? VersionInfoModel.fromJson(json['version'] as Map<dynamic, dynamic>)
        : null;
    manufacturer = json['manufacturer'] as String?;
    tags = json['tags'] as String?;
    bootloader = json['bootloader'] as String?;
    fingerprint = json['fingerprint'] as String?;
    host = json['host'] as String?;
    model = json['model'] as String?;
    id = json['id'] as String?;
    isDeviceRoot = json['isDeviceRoot'] as bool?;
    brand = json['brand'] as String?;
    device = json['device'] as String?;
    board = json['board'] as String?;
    androidId = json['androidId'] as String?;
    hardware = json['hardware'] as String?;

    /// only ios
    systemName = json['systemName'] as String?;
    uts = json['uts'] != null
        ? UTSModel.fromJson(json['uts'] as Map<dynamic, dynamic>)
        : null;
    uuid = json['uuid'] as String?;
    localizedModel = json['localizedModel'] as String?;
    systemVersion = json['systemVersion'] as String?;
    name = json['name'] as String?;
    address = json['address'] as String?;
    final List<dynamic>? addressesList = json['addresses'] as List<dynamic>?;
    if (addressesList != null && addressesList.isNotEmpty) {
      addresses = addressesList.map((dynamic e) => e as String).toList();
    }
  }

  /// Android and IOS
  bool? isEmulator;
  String? model;

  /// only Android
  String? product;
  String? display;
  String? type;
  VersionInfoModel? version;
  String? manufacturer;
  String? tags;
  String? bootloader;
  String? fingerprint;
  String? host;
  String? id;
  bool? isDeviceRoot;
  String? brand;
  String? device;
  String? board;
  String? androidId;
  String? hardware;

  /// only ios
  String? systemName;
  String? uuid;
  String? systemVersion;

  /// only ios and macOS
  String? localizedModel;
  UTSModel? uts;
  String? name;

  /// only macOS
  String? address;
  List<String>? addresses;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'isEmulator': isEmulator,
        'model': model,

        /// only Android
        'product': product,
        'display': display,
        'type': type,
        'version': version == null ? null : version!.toMap(),
        'manufacturer': manufacturer,
        'tags': tags,
        'bootloader': bootloader,
        'fingerprint': fingerprint,
        'host': host,
        'id': id,
        'isDeviceRoot': isDeviceRoot,
        'brand': brand,
        'device': device,
        'board': board,
        'androidId': androidId,
        'hardware': hardware,

        /// only ios
        'systemName': systemName,
        'uuid': uuid,
        'uts': uts == null ? null : uts!.toMap(),
        'localizedModel': localizedModel,
        'systemVersion': systemVersion,
        'name': name,
        'address': address,
        'addresses': addresses
      };
}

class VersionInfoModel {
  VersionInfoModel.fromJson(Map<dynamic, dynamic> json) {
    baseOS = json['baseOS'] as String?;
    securityPatch = json['securityPatch'] as String?;
    sdkInt = json['sdkInt'] as int?;
    release = json['release'] as String?;
    codename = json['codename'] as String?;
    previewSdkInt = json['previewSdkInt'] as int?;
    incremental = json['incremental'] as String?;
  }

  String? baseOS;
  String? securityPatch;
  int? sdkInt;
  String? release;
  String? codename;
  int? previewSdkInt;
  String? incremental;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'baseOS': baseOS,
        'securityPatch': securityPatch,
        'sdkInt': sdkInt,
        'release': release,
        'codename': codename,
        'previewSdkInt': previewSdkInt,
        'incremental': incremental
      };
}

class UTSModel {
  UTSModel.fromJson(Map<dynamic, dynamic> json) {
    release = json['release'] as String?;
    sysName = json['sysName'] as String?;
    nodeName = json['nodeName'] as String?;
    machine = json['machine'] as String?;
    version = json['version'] as String?;
  }

  String? release;
  String? sysName;
  String? nodeName;
  String? machine;
  String? version;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'release': release,
        'sysName': sysName,
        'nodeName': nodeName,
        'machine': machine,
        'version': version
      };
}

/// macos 保存文件选择器
class SaveFilePickerOptionsWithMacOS {
  SaveFilePickerOptionsWithMacOS(
      {this.nameFieldLabel = '',
      this.nameFieldStringValue = 'file',
      this.tagNames = const <String>[],
      this.canSelectHiddenExtension = true,
      this.showsTagField = true,
      this.isExtensionHidden = true,
      this.canCreateDirectories = true,
      this.isModal = true,
      this.allowedFileTypes,
      this.directoryURL = '',
      this.prompt = 'prompt',
      this.title = 'title',
      this.message = 'message'});

  /// 默认打开的路径
  late String directoryURL;

  /// 可以选择的文件类型 或储存的可选类型
  List<String>? allowedFileTypes;

  ///  默认的“打开”那两个字
  late String prompt;

  /// 面板显示的信息
  late String message;

  /// 标题
  late String title;

  /// 默认储存的标签文本。
  late String nameFieldLabel;

  /// 默认储存的文件名
  late String nameFieldStringValue;

  /// tagName
  late List<String> tagNames;

  /// 是否可以创建文件夹
  late bool canCreateDirectories;

  /// 指示面板是显示用于隐藏还是显示文件扩展名的 UI
  late bool canSelectHiddenExtension;

  /// 一个布尔值，指示面板是否显示通常对用户隐藏的文件
  late bool showsTagField;

  /// 指示面板是否展开
  late bool isExtensionHidden;

  /// 是否使用模态弹窗
  late bool isModal;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'allowedFileTypes': allowedFileTypes,
        'directoryURL': directoryURL,
        'prompt': prompt,
        'message': message,
        'title': title,
        'nameFieldLabel': nameFieldLabel,
        'nameFieldStringValue': nameFieldStringValue,
        'isExtensionHidden': isExtensionHidden,
        'showsTagField': showsTagField,
        'canSelectHiddenExtension': canSelectHiddenExtension,
        'canCreateDirectories': canCreateDirectories,
        'tagNames': tagNames,
        'isModal': isModal
      };
}

/// macos 文件选择器
class FilePickerOptionsWithMacOS extends SaveFilePickerOptionsWithMacOS {
  FilePickerOptionsWithMacOS(
      {this.canChooseFiles = true,
      this.canChooseDirectories = false,
      this.resolvesAliases = true,
      bool isModal = true,
      this.allowsMultipleSelection = false,
      this.canDownloadUbiquitousContents = false,
      this.canResolveUbiquitousConflicts = false,
      String title = 'title',
      String nameFieldLabel = '',
      String nameFieldStringValue = '',
      List<String> tagNames = const <String>[],
      bool canSelectHiddenExtension = true,
      bool showsTagField = true,
      bool isExtensionHidden = true,
      bool canCreateDirectories = true,
      List<String>? allowedFileTypes,
      String directoryURL = '',
      String prompt = 'prompt',
      String message = 'message'})
      : super(
            isModal: isModal,
            allowedFileTypes: allowedFileTypes,
            directoryURL: directoryURL,
            prompt: prompt,
            message: message,
            title: title,
            nameFieldLabel: nameFieldLabel,
            nameFieldStringValue: nameFieldStringValue,
            tagNames: tagNames,
            canSelectHiddenExtension: canSelectHiddenExtension,
            showsTagField: showsTagField,
            isExtensionHidden: isExtensionHidden,
            canCreateDirectories: canCreateDirectories);

  /// 是否能选择文件file
  late bool canChooseFiles;

  /// 是否能打开文件夹
  late bool canChooseDirectories;

  /// 指示面板是否解析别名
  late bool resolvesAliases;

  /// 是否允许多选
  late bool allowsMultipleSelection;

  /// 指示面板如何响应本地未完全下载的iCloud文档。
  late bool canDownloadUbiquitousContents;

  /// 指示面板如何响应具有冲突版本的iCloud文档
  late bool canResolveUbiquitousConflicts;

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        ...super.toMap(),
        'canChooseFiles': canChooseFiles,
        'canChooseDirectories': canChooseDirectories,
        'resolvesAliases': resolvesAliases,
        'allowsMultipleSelection': allowsMultipleSelection,
        'canDownloadUbiquitousContents': canDownloadUbiquitousContents,
        'canResolveUbiquitousConflicts': canResolveUbiquitousConflicts,
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

class AndroidRequestPermissionsResult {
  AndroidRequestPermissionsResult.formJson(Map<dynamic, dynamic> json) {
    requestCode = (json['requestCode'] as int?) ?? 0;
    final List<dynamic> _permissions = json['permissions'] as List<dynamic>;
    permissions = _permissions.map((dynamic e) => e as String).toList();
    final List<dynamic> _grantResults = json['grantResults'] as List<dynamic>;
    grantResults = _grantResults.map((dynamic e) => e as int).toList();
  }

  late int requestCode;
  late List<String> permissions;
  late List<int> grantResults;
}
