import 'package:permission_handler/permission_handler.dart';

class Utils {
  static requestPermissions(Permission permission, String text,
      {bool showAlert: true}) async {
    var status = await permission.status;
    if (status != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> statuses = await [permission].request();
      if (!(statuses[permission] == PermissionStatus.granted)) {
        openAppSettings();
      }
      return statuses[permission] == PermissionStatus.granted;
    }
    return true;
  }
}
