import CoreLocation
import Foundation

let fileManager = FileManager.default

public enum NativeTools {
    public static func getDeviceInfo() -> [AnyHashable: Any]? {
        let device = UIDevice.current
        var un = utsname()
        uname(&un)
        return [
            "name": device.name,
            "systemName": device.systemName,
            "systemVersion": device.systemVersion,
            "model": device.model,
            "uuid": device.identifierForVendor?.uuidString ?? "",
            "localizedModel": device.localizedModel,
            "isEmulator": Tools.isEmulator(),
            "uts": [
                "sysName": un.sysname,
                "nodeName": un.nodename,
                "release": un.release,
                "version": un.version,
                "machine": un.machine
            ]
        ]
    }

    public static func getAppInfo() -> [AnyHashable: Any?]? {
        let app = Bundle.main.infoDictionary
        let statusBar = UIApplication.shared.statusBarFrame
        return [
            "statusBarHeight": statusBar.size.height,
            "statusBarWidth": statusBar.size.width,
            "homeDirectory": NSHomeDirectory(),
            "documentDirectory": NSHomeDirectory() + "/Documents",
            "libraryDirectory": NSHomeDirectory() + "/Library",
            "cachesDirectory": NSHomeDirectory() + "/Library/Caches",
            "temporaryDirectory": NSTemporaryDirectory(),
            "versionName": app?["CFBundleShortVersionString"],
            "versionCode": Int(app?["CFBundleVersion"] as! String),
            "packageName": app?["CFBundleIdentifier"],
            "appName": app?["CFBundleName"],
            "sdkBuild": app?["DTSDKBuild"],
            "platformName": app?["DTPlatformName"],
            "minimumOSVersion": app?["MinimumOSVersion"],
            "platformVersion": app?["DTPlatformVersion"]
        ]
    }

    // 跳转到设置页面让用户自己手动开启
    public static func openSystemSetting() -> Bool {
        let url = URL(string: UIApplication.openSettingsURLString)
        if let url = url {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
                return true
            }
        }
        return false
    }

    // 判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
    public static func getGPSStatus() -> Bool {
        CLLocationManager.locationServicesEnabled()
    }
}
