import FlutterMacOS
import Foundation

class DesktopTools {
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
        let window = NSApplication.shared.mainWindow
        if width != nil, height != nil, window != nil {
            var rect = window!.frame
            rect.origin.y += (rect.size.height - CGFloat(height!))
            rect.size.width = CGFloat(width!)
            rect.size.height = CGFloat(height!)
            window!.animator().setFrame(rect, display: true, animate: true)
            return true
        }
        return false
    }

    static func setMinWindowSize(_ call: FlutterMethodCall) -> Bool {
        let arguments = call.arguments as! [String: Any]
        let width = arguments["width"] as? Double
        let height = arguments["height"] as? Double
        let window = NSApplication.shared.mainWindow
        if width != nil, height != nil, window != nil {
            window!.minSize = CGSize(width: CGFloat(width!), height: CGFloat(height!))
            return true
        }
        return false
    }

    static func setMaxWindowSize(_ call: FlutterMethodCall) -> Bool {
        let arguments = call.arguments as! [String: Any]
        let width = arguments["width"] as? Double
        let height = arguments["height"] as? Double
        let window = NSApplication.shared.mainWindow
        if width != nil, height != nil, window != nil {
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
        let window = NSApplication.shared.mainWindow
        window?.maxSize = CGSize(
                width: CGFloat(Float.greatestFiniteMagnitude),
                height: CGFloat(Float.greatestFiniteMagnitude))
        return true
    }

    static func toggleFullScreen() -> Bool {
        let window = NSApplication.shared.mainWindow
        window?.toggleFullScreen(nil)
        return true
    }

    static func setFullScreen(_ call: FlutterMethodCall) -> Bool {
        let arguments = call.arguments as! [String: Any]
        let fullScreen = arguments["fullscreen"] as? Bool
        let window = NSApplication.shared.mainWindow
        if fullScreen != nil, window != nil {
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
        let window = NSApplication.shared.mainWindow
        if window != nil {
            return window!.styleMask.contains(.fullScreen)
        }
        return nil
    }

    static func hasBorders() -> Bool? {
        let window = NSApplication.shared.mainWindow
        if window != nil {
            return window!.styleMask.contains(.borderless)
        }
        return nil
    }

    static func toggleBorders() -> Bool? {
        let window = NSApplication.shared.mainWindow
        if window != nil {
            if window!.styleMask.contains(.borderless) {
                window!.styleMask.remove(.borderless)
            } else {
                window!.styleMask.insert(.borderless)
            }
            return true
        }
        return nil
    }

    static func setBorders(_ call: FlutterMethodCall) -> Bool? {
        let window = NSApplication.shared.mainWindow
        if window != nil {
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
        return nil
    }

    static func stayOnTop(_ call: FlutterMethodCall) -> Bool? {
        let window = NSApplication.shared.mainWindow
        if window != nil {
            if let bstayOnTop: Bool = (call.arguments as? [String: Any])?["stayOnTop"] as? Bool {
                window!.level = bstayOnTop ? .floating : .normal
                return true
            }
            return false
        }
        return nil
    }
}
