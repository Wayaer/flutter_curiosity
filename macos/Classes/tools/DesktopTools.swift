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
        let window = NSApplication.shared.mainWindow
        if window != nil, let width: Float = (call.arguments as? [String: Any])?["width"] as? Float,
           let height: Float = (call.arguments as? [String: Any])?["height"] as? Float
        {
            var rect = window!.frame
            rect.origin.y += (rect.size.height - CGFloat(height))
            rect.size.width = CGFloat(width)
            rect.size.height = CGFloat(height)
            window!.setFrame(rect, display: true)
            return true
        }
        return false
    }

    static func setMinWindowSize(_ call: FlutterMethodCall) -> Bool {
        let window = NSApplication.shared.mainWindow
        if window != nil, let width: Float = (call.arguments as? [String: Any])?["width"] as? Float,
           let height: Float = (call.arguments as? [String: Any])?["height"] as? Float
        {
            window!.minSize = CGSize(width: CGFloat(width), height: CGFloat(height))
            return true
        }
        return false
    }

    static func setMaxWindowSize(_ call: FlutterMethodCall) -> Bool {
        let window = NSApplication.shared.mainWindow
        if window != nil, let width: Float = (call.arguments as? [String: Any])?["width"] as? Float,
           let height: Float = (call.arguments as? [String: Any])?["height"] as? Float
        {
            if width == 0 || height == 0 {
                window!.maxSize = CGSize(
                    width: CGFloat(Float.greatestFiniteMagnitude),
                    height: CGFloat(Float.greatestFiniteMagnitude))
            } else {
                window?.maxSize = CGSize(width: CGFloat(width), height: CGFloat(height))
            }
            return true
        }
        return false
    }

    static func resetMaxWindowSize() -> Bool {
        let window = NSApplication.shared.mainWindow
        if window != nil {
            window!.maxSize = CGSize(
                width: CGFloat(Float.greatestFiniteMagnitude),
                height: CGFloat(Float.greatestFiniteMagnitude))
            return true
        }
        return false
    }

    static func toggleFullScreen() -> Bool {
        let window = NSApplication.shared.mainWindow
        if window != nil { window!.toggleFullScreen(nil)
            return true
        }
        return false
    }

    static func setFullScreen(_ call: FlutterMethodCall) -> Bool {
        let window = NSApplication.shared.mainWindow
        if window != nil, let fullScreen: Bool = (call.arguments as? [String: Any])?["fullscreen"] as? Bool {
            if fullScreen {
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

    static func hasBorders() -> Bool {
        let window = NSApplication.shared.mainWindow
        if window != nil {
            return window!.styleMask.contains(.borderless)
        }
        return false
    }

    static func toggleBorders() -> Bool {
        let window = NSApplication.shared.mainWindow
        if window != nil {
            if window!.styleMask.contains(.borderless) {
                window!.styleMask.remove(.borderless)
            } else {
                window!.styleMask.insert(.borderless)
            }
            return true
        }
        return false
    }

    static func setBorders(_ call: FlutterMethodCall) -> Bool {
        let window = NSApplication.shared.mainWindow
        if window != nil, let bBorders: Bool = (call.arguments as? [String: Any])?["borders"] as? Bool {
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
        let window = NSApplication.shared.mainWindow
        if window != nil, let bstayOnTop: Bool = (call.arguments as? [String: Any])?["stayOnTop"] as? Bool {
            window!.level = bstayOnTop ? .floating : .normal
            return true
        }
        return false
    }
}