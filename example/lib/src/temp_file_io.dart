import 'dart:io';
import 'dart:typed_data';

/// Writes [bytes] to a PNG file in the system temp directory.
Future<String?> writeTempPng(Uint8List bytes) async {
  final File file = File('${Directory.systemTemp.path}/curiosity_${DateTime.now().millisecondsSinceEpoch}.png');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
