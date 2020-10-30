import 'package:permission_handler/permission_handler.dart';

class Utils {
  static Future<bool> requestPermissions(Permission permission, String text,
      {bool showAlert = true}) async {
    final PermissionStatus status = await permission.status;
    if (status != PermissionStatus.granted) {
      final Map<Permission, PermissionStatus> statuses =
          await <Permission>[permission].request();
      if (!(statuses[permission] == PermissionStatus.granted)) {
        openAppSettings();
      }
      return statuses[permission] == PermissionStatus.granted;
    }
    return true;
  }
}
