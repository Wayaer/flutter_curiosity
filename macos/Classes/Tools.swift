import Foundation

class Tools {
    static func log(_ info: Any?) {
        print("CuriosityLog =")
        print(info ?? "null")
    }

    static func resultInfo(_ info: String) -> String {
        info
    }

    static func resultFail(_ info: String) -> String {
        "fail"
    }

    static func resultSuccess(_ info: String) -> String {
        "success"
    }

    static func isEmulator() -> Bool {
        (TARGET_IPHONE_SIMULATOR == 1) && (TARGET_OS_IPHONE == 1)
    }

    static func openUrl(_ url: String) -> Bool {
        let _url = URL(string: url)
        if _url != nil, NSWorkspace.shared.urlForApplication(toOpen: _url!) != nil {
            NSWorkspace.shared.open(_url!)
            return true
        }
        return false
    }

    static func isImageFile(_ path: String) -> Bool {
        path.hasSuffix(".jpg")
                || path.hasSuffix(".png")
                || path.hasSuffix(".PNG")
                || path.hasSuffix(".JPEG")
                || path.hasSuffix(".JPG")
                || path.hasSuffix(".GiF")
                || path.hasSuffix(".gif")
    }
}
