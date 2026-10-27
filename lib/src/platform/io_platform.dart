import 'dart:io';

import 'package:flutter/foundation.dart';

/// Dart-only desktop support for Windows and Linux.
///
/// Only used when the current platform is Windows or Linux. macOS keeps using
/// the native method channel implementation.
class IoPlatform {
  static const Set<String> _videoExtensions = <String>{
    'mp4',
    'mov',
    'avi',
    'flv',
    'wmv',
    'mkv',
    'webm',
    'mpeg',
    'mpg',
    '3gp',
    'm4v',
    'rmvb',
    'ts',
    'mts',
  };

  /// Exits the app process.
  static Future<bool> exitApp() async {
    exit(0);
  }

  /// Saves [bytes] to the Pictures folder.
  static Future<bool> saveBytesImage(Uint8List bytes, String name, String extension) async {
    final Directory? directory = _mediaDirectory(extension);
    if (directory == null) return false;
    try {
      await directory.create(recursive: true);
      final File file = _uniqueFile(directory, _sanitizeName(name), extension);
      await file.writeAsBytes(bytes, flush: true);
      return true;
    } on FileSystemException catch (e) {
      debugPrint('IoPlatform.saveBytesImage failed: $e');
      return false;
    }
  }

  /// Copies the file located at [path] to the Pictures or Videos folder.
  static Future<bool> saveFilePath(String path, String name, String extension) async {
    final File source = File(path);
    if (!await source.exists()) return false;
    final Directory? directory = _mediaDirectory(extension);
    if (directory == null) return false;
    try {
      await directory.create(recursive: true);
      final File target = _uniqueFile(directory, _sanitizeName(name), extension);
      await source.copy(target.path);
      return true;
    } on FileSystemException catch (e) {
      debugPrint('IoPlatform.saveFilePath failed: $e');
      return false;
    }
  }

  /// Returns the Pictures or Videos directory for [extension].
  static Directory? _mediaDirectory(String extension) {
    final Map<String, String> environment = Platform.environment;
    final bool isVideo = _videoExtensions.contains(extension.toLowerCase());
    if (Platform.isWindows) {
      final String? userProfile = environment['USERPROFILE'];
      if (userProfile == null) return null;
      return Directory('$userProfile\\${isVideo ? 'Videos' : 'Pictures'}');
    }
    if (Platform.isLinux) {
      final String? home = environment['HOME'];
      final String? xdgDirectory = environment[isVideo ? 'XDG_VIDEOS_DIR' : 'XDG_PICTURES_DIR'];
      if (xdgDirectory != null && xdgDirectory.isNotEmpty) {
        if (xdgDirectory.startsWith('/')) return Directory(xdgDirectory);
        if (home == null) return null;
        return Directory('$home/$xdgDirectory');
      }
      if (home == null) return null;
      return Directory('$home/${isVideo ? 'Videos' : 'Pictures'}');
    }
    return null;
  }

  /// Returns a file that does not overwrite an existing file.
  static File _uniqueFile(Directory directory, String name, String extension) {
    final String suffix = extension.isEmpty ? '' : '.$extension';
    File file = File('${directory.path}${Platform.pathSeparator}$name$suffix');
    int index = 1;
    while (file.existsSync()) {
      file = File('${directory.path}${Platform.pathSeparator}$name ($index)$suffix');
      index++;
    }
    return file;
  }

  /// Removes characters that are not allowed in file names.
  static String _sanitizeName(String name) {
    final String sanitized = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    if (sanitized.isNotEmpty) return sanitized;
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
