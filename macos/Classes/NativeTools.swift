import AppKit
import CoreLocation
import Foundation

class NativeTools {
    static func getDeviceInfo() -> [AnyHashable: Any?]? {
        let device = Host.current()
        var un = utsname()
        uname(&un)
        return [
            "name": device.name,
            "address": device.address,
            "addresses": device.addresses,
            "localizedName": device.localizedName,
            "uts": [
                "sysName": getUTS(un.sysname),
                "nodeName": getUTS(un.nodename),
                "release": getUTS(un.release),
                "version": getUTS(un.version),
                "machine": getUTS(un.machine)
            ]
        ]
    }

    static func getUTS(_ subject: Any) -> String {
        let mirror = Mirror(reflecting: subject)
        let identifier = mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
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
            "temporaryDirectory": NSTemporaryDirectory()
        ]
    }

    static func getAppInfo() -> [AnyHashable: Any?]? {
        let appInfo = Bundle.main.infoDictionary
        return [
            "versionName": appInfo?["CFBundleShortVersionString"],
            "versionCode": Int(appInfo?["CFBundleVersion"] as! String),
            "packageName": appInfo?["CFBundleIdentifier"],
            "appName": appInfo?["CFBundleName"],
            "sdkBuild": appInfo?["DTSDKBuild"],
            "platformName": appInfo?["DTPlatformName"],
            "minimumOSVersion": appInfo?["MinimumOSVersion"],
            "platformVersion": appInfo?["DTPlatformVersion"]
        ]
    }

    static func getDirectoryOfType(_ directory: FileManager.SearchPathDirectory) -> String {
        let path = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)
        return path.first! as String
    }

    // 判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
    static func getGPSStatus() -> Bool {
        CLLocationManager.locationServicesEnabled()
    }
}