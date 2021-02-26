
import Foundation

var curiosity="Curiosity"
let _fileManage=FileManager.init();
public class Tools{
    
    
    func log(info: String) {
//        log(curiosity+"Log:", info)
    }
    
    func nameresultInfo(info: String) -> NSString{
        return curiosity+":"+info
    }
    
    func resultFail() -> NSString {
        return curiosity+":fail"
    }
    
    func resultSuccess() -> NSString {
        return curiosity+":success"
    }
    
    //沙盒是否有指定路径文件夹或文件
    func isDirectoryExist(path: String) ->Bool{
        return _fileManage.fileExists(atPath: path)
    }
    // 是否是文件夹
    func isDirectory(path: String) -> Bool {
        var isDir=false
        _fileManage.fileExists(path, isDirectory:isDir)
        return isDir
    }
    
    func isImageFile(NSString: path) -> bool {
        path.hasSuffix(".jpg")||
        
        return false
    }
    
}
