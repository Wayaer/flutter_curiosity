import Foundation

class Tools {
    static func log(_ info: Any?) {
        print("CuriosityLog =")
        print(info ?? "null")
    }
    
    static func resultInfo(_ info: String) -> String {
        return info
    }
    
    static func resultFail(_ info: String) -> String {
        return "fail"
    }
    
    static func resultSuccess(_ info: String) -> String {
        return "success"
    }
    
    static func isEmulator() -> Bool {
        return (TARGET_IPHONE_SIMULATOR == 1) && (TARGET_OS_IPHONE == 1)
    }
    
    static func isImageFile(_ path: String) -> Bool {
        return path.hasSuffix(".jpg")
            || path.hasSuffix(".png")
            || path.hasSuffix(".PNG")
            || path.hasSuffix(".JPEG")
            || path.hasSuffix(".JPG")
            || path.hasSuffix(".GiF")
            || path.hasSuffix(".gif")
    }
}
