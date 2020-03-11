import Foundation
import UIKit

class NativeUtils  {
    //获取app信息
    
    class func getAppInfo() -> [AnyHashable : Any]? {
        let app = Bundle.main.infoDictionary
        let statusBar = UIApplication.shared.statusBarFrame
        let device = UIDevice.current
        let  info: [AnyHashable : Any] = [
            
            AnyHashable("statusBarHeight") : NSNumber(value: Float(statusBar.size.height)),
            AnyHashable("statusBarWidth") : NSNumber(value: Float(statusBar.size.width)),
            
            AnyHashable("homeDirectory") : NSHomeDirectory(),
            AnyHashable("documentDirectory") : NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first as Any,
            AnyHashable("libraryDirectory") : NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last as Any,
            AnyHashable("cachesDirectory") : NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first as Any,
            AnyHashable("temporaryDirectory") : NSTemporaryDirectory(),
            
            AnyHashable("versionName") : app?["CFBundleShortVersionString"] as Any,
            AnyHashable("phoneBrand") : "Apple",
            AnyHashable("versionCode") : NSNumber(value: Int32((app?["CFBundleVersion"] as? NSNumber)?.intValue ?? 0)),
            
            AnyHashable("packageName") : app?["CFBundleIdentifier"] as Any,
            AnyHashable("appName") : app?["CFBundleName"] as Any,
            AnyHashable("sdkBuild") : app?["DTSDKBuild"] as Any,
            AnyHashable("platformName") : app?["DTPlatformName"] as Any,
            AnyHashable("pinimumOSVersion") : app?["MinimumOSVersion"] as Any,
            AnyHashable("platformVersion") : app?["DTPlatformVersion"] as Any,
            
            AnyHashable("systemName") : device.systemName,
            AnyHashable("systemVersion") : device.systemVersion,
        ]
        
        return info
    }
    
    //Log
    class  func log(info: Any?) {
        if let info = info {
            print("Curiosity--- \(info)")
        }
    }
    
    //跳转到AppStore
    class func goToMarket(id: String) {
    
        let url = "itms-apps://itunes.apple.com/us/app/id"+call.arguments!["packageName"] as! String
        UIApplication.shared.openURL(URL(string: url)!)
        
    }
    //设置Cookie
    class func setCookie(props: [AnyHashable : Any]?) {
        
        let properties: [AnyHashable : Any] = [
            AnyHashable(HTTPCookiePropertyKey.name):props?["name"] as Any,
            AnyHashable(HTTPCookiePropertyKey.value):props?["value"] as Any,
            AnyHashable(HTTPCookiePropertyKey.domain):props?["domain"] as Any,
            AnyHashable(HTTPCookiePropertyKey.originURL):props?["origin"] as Any,
            AnyHashable(HTTPCookiePropertyKey.path):props?["path"] as Any,
            AnyHashable(HTTPCookiePropertyKey.expires):props?["expiration"] as Any,
        ]
        
        var cookie: HTTPCookie? = nil
        if let cookieProperties = properties as? [HTTPCookiePropertyKey : Any] {
            cookie = HTTPCookie(properties: cookieProperties)
        }
        if let cookie = cookie {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
    }
    
    //清楚Cookie
    
    class  func clearAllCookie() {
        let cookieStorage = HTTPCookieStorage.shared
        for c in cookieStorage.cookies ?? [] {
            cookieStorage.deleteCookie(c)
        }
    }
    
    //获取Cookie
    class  func getAllCookie() -> [AnyHashable : Any]? {
        let cookieStorage = HTTPCookieStorage.shared
        var cookies: [AnyHashable : Any] = [:]
        for c in cookieStorage.cookies ?? [] {
            let map : [AnyHashable : Any] = [
                AnyHashable("name"):c.name,
                AnyHashable("value"):c.value,
                AnyHashable("domain"):c.domain,
                AnyHashable("path"):c.path
            ]
            cookies[c.name]=map
            
        }
        return cookies
    }
    
}
