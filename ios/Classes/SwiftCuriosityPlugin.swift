import Flutter
import UIKit

public class SwiftCuriosityPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "Curiosity", binaryMessenger: (registrar.messenger()))
         
        let viewController = UIApplication.shared.delegate?.window?!.rootViewController
        let instance = SwiftCuriosityPlugin(_viewController:viewController!)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.register(ScanViewFactory(messenger: registrar.messenger()), withId: "scanView")
        
    }
    
    private var viewController: UIViewController
    private var call: FlutterMethodCall

    public func handle(_call: FlutterMethodCall, result: @escaping FlutterResult) {
        call = _call
        gallery(result: result)
        scan(result: result)
        utils(result: result)
    }


    public  init(_viewController: UIViewController) {
        super.init()
        viewController = _viewController
    }

    func gallery(result: FlutterResult) {
        if ("openPicker" == call.method) {
            PicturePicker.openPicker(call.arguments, viewController: viewController, result: result)
        } else if ("openCamera" == call.method) {
            PicturePicker.openCamera(call.arguments, viewController: viewController, result: result)
        } else if ("deleteCacheDirFile" == call.method) {
            PicturePicker.deleteCacheDirFile()
        }
    }
    func scan(result: FlutterResult) {
        if ("scanImagePath" == call.method) {
            ScanUtils.scanImagePath(call, result: result)
        } else if ("scanImageUrl" == call.method) {
            ScanUtils.scanImageUrl(call, result: result)
        }
        if ("scanImageMemory" == call.method) {
            ScanUtils.scanImageMemory(call, result: result)
        }
    }
    func utils(result: FlutterResult) {
        if ("clearAllCookie" == call.method) {
            NativeUtils.clearAllCookie()
            result("success")
        } else if ("getAllCookie" == call.method) {
            result(NativeUtils.getAllCookie())
        } else if ("getFilePathSize" == call.method) {
            result(FileUtils.getFilePathSize(call.arguments["filePath"]))
        } else if ("deleteDirectory" == call.method) {
            FileUtils.deleteDirectory(call.arguments["directoryPath"])
            result("success")
        } else if ("deleteFile" == call.method) {
            FileUtils.deleteFile(call.arguments["filePath"])
            result("success")
        } else if ("unZipFile" == call.method) {
            FileUtils.unZipFile(call.arguments["filePath"])
            result("success")
        } else if ("goToMarket" == call.method) {
            NativeUtils.goToMarket(id: )
            result("success")
        }  else if ("getAppInfo" == call.method) {
            result(NativeUtils.getAppInfo())
        } else if ("getDirectoryAllName" == call.method) {
            result(FileUtils.getDirectoryAllName(arguments: call.arguments as Any))
        } else if ("exitApp" == call.method) {
            exit(0)
        }

    }


}
