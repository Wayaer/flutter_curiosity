import CoreLocation
import Foundation
import UIKit

class NativeTools {
    static func getDeviceInfo() -> [AnyHashable: Any]? {
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
                "sysName": getUTS(un.sysname),
                "nodeName": getUTS(un.nodename),
                "release": getUTS(un.release),
                "version": getUTS(un.version),
                "machine": getUTS(un.machine),
            ],
        ]
    }

    static func getUTS(_ subject: Any) -> String {
        let mirror = Mirror(reflecting: subject)
        let identifier = mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    static func getAppPath() -> [AnyHashable: Any?]? {
        [
            "homeDirectory": NSHomeDirectory(),
            "documentDirectory": getDirectoryOfType(.documentDirectory),
            "libraryDirectory": getDirectoryOfType(.libraryDirectory),
            "cachesDirectory": getDirectoryOfType(.cachesDirectory),
            "directoryMusic": getDirectoryOfType(.musicDirectory),
            "directoryDownloads": getDirectoryOfType(.downloadsDirectory),
            "directoryMovies": getDirectoryOfType(.moviesDirectory),
            "directoryPictures": getDirectoryOfType(.picturesDirectory),
            "directoryDocuments": getDirectoryOfType(.documentDirectory),
            "applicationSupportDirectory": getDirectoryOfType(.applicationSupportDirectory),
            "applicationDirectory": getDirectoryOfType(.applicationDirectory),
            "temporaryDirectory": NSTemporaryDirectory(),
        ]
    }

    static func getAppInfo() -> [AnyHashable: Any?]? {
        let appInfo = Bundle.main.infoDictionary
        let statusBar = UIApplication.shared.statusBarFrame
        return [
            "statusBarHeight": statusBar.size.height,
            "statusBarWidth": statusBar.size.width,
            "versionName": appInfo?["CFBundleShortVersionString"],
            "versionCode": Int(appInfo?["CFBundleVersion"] as! String),
            "packageName": appInfo?["CFBundleIdentifier"],
            "appName": appInfo?["CFBundleName"],
            "sdkBuild": appInfo?["DTSDKBuild"],
            "platformName": appInfo?["DTPlatformName"],
            "minimumOSVersion": appInfo?["MinimumOSVersion"],
            "platformVersion": appInfo?["DTPlatformVersion"],
        ]
    }

    static func getDirectoryOfType(_ directory: FileManager.SearchPathDirectory) -> String {
        let path = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)
        return path.first! as String
    }

    // 跳转到设置页面让用户自己手动开启
    static func openSystemSetting() -> Bool {
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
    static func getGPSStatus() -> Bool {
        CLLocationManager.locationServicesEnabled()
    }
}
