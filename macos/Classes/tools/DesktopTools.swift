import FlutterMacOS
import Foundation

class DesktopTools {
    static let window = NSApplication.shared.mainWindow

    static func getWindowSize() -> [CGFloat?] {
        let window = NSApplication.shared.mainWindow
        let width = window?.frame.size.width
        let height = window?.frame.size.height
        return [width, height]
    }

    static func setWindowSize(_ call: FlutterMethodCall) -> Bool {
        let arguments = call.arguments as! [String: Any]
        let width = arguments["width"] as? Double
        let height = arguments["height"] as? Double
        if width != nil, height != nil {
            var rect = window!.frame
            rect.origin.y += (rect.size.height - CGFloat(height!))
            rect.size.width = CGFloat(width!)
            rect.size.height = CGFloat(height!)
            window!.setFrame(rect, display: true)
            return true
        }
        return false
    }

    static func setMinWindowSize(_ call: FlutterMethodCall) -> Bool {
        let arguments = call.arguments as! [String: Any]
        let width = arguments["width"] as? Double
        let height = arguments["height"] as? Double
        if width != nil, height != nil {
            window!.minSize = CGSize(width: CGFloat(width!), height: CGFloat(height!))
            return true
        }
        return false
    }

    static func setMaxWindowSize(_ call: FlutterMethodCall) -> Bool {
        let arguments = call.arguments as! [String: Any]
        let width = arguments["width"] as? Double
        let height = arguments["height"] as? Double
        if width != nil, height != nil {
            if width == 0 || height == 0 {
                window!.maxSize = CGSize(
                    width: CGFloat(Float.greatestFiniteMagnitude),
                    height: CGFloat(Float.greatestFiniteMagnitude))
            } else {
                window?.maxSize = CGSize(width: CGFloat(width!), height: CGFloat(height!))
            }
            return true
        }
        return false
    }

    static func resetMaxWindowSize() -> Bool {
        window!.maxSize = CGSize(
            width: CGFloat(Float.greatestFiniteMagnitude),
            height: CGFloat(Float.greatestFiniteMagnitude))
        return true
    }

    static func toggleFullScreen() -> Bool {
        window!.toggleFullScreen(nil)
        return true
    }

    static func setFullScreen(_ call: FlutterMethodCall) -> Bool {
        let arguments = call.arguments as! [String: Any]
        let fullScreen = arguments["fullscreen"] as? Bool
        if fullScreen != nil {
            if fullScreen! {
                if !window!.styleMask.contains(.fullScreen) {
                    window!.toggleFullScreen(nil)
                }
            } else {
                if window!.styleMask.contains(.fullScreen) {
                    window!.toggleFullScreen(nil)
                }
            }
            return true
        }
        return false
    }

    static func getFullScreen() -> Bool? {
        window!.styleMask.contains(.fullScreen)
    }

    static func hasBorders() -> Bool {
        window!.styleMask.contains(.borderless)
    }

    static func toggleBorders() -> Bool {
        if window!.styleMask.contains(.borderless) {
            window!.styleMask.remove(.borderless)
        } else {
            window!.styleMask.insert(.borderless)
        }
        return true
    }

    static func setBorders(_ call: FlutterMethodCall) -> Bool {
        if let bBorders: Bool = (call.arguments as? [String: Any])?["borders"] as? Bool {
            if window!.styleMask.contains(.borderless) == bBorders {
                if bBorders {
                    window!.styleMask.remove(.borderless)
                } else {
                    window!.styleMask.insert(.borderless)
                }
            }
            return true
        }
        return false
    }

    static func stayOnTop(_ call: FlutterMethodCall) -> Bool {
        if let bstayOnTop: Bool = (call.arguments as? [String: Any])?["stayOnTop"] as? Bool {
            window!.level = bstayOnTop ? .floating : .normal
            return true
        }
        return false
    }
}
