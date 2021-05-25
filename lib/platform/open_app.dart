import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/tools/internal.dart';

Future<bool> openPhone(String phone) async {
  if (!supportPlatform) return false;
  final String url = 'tel:$phone';
  if (await canOpenUrl(url)) {
    await openUrl(url);
    return true;
  }
  return false;
}

Future<bool> openSMS(String phone) async {
  if (!supportPlatform) return false;
  final String url = 'sms:$phone';
  if (await canOpenUrl(url)) {
    await openUrl(url);
    return true;
  }
  return false;
}
