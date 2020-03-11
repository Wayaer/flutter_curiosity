import Foundation


let fileManager = FileManager.default
let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last

class FileUtils {
    // 删除沙盒指定文件或文件夹
    class func deleteFile(path: String) {
        if isDirectoryExist(path: path) {
            //移除文件
            try! fileManager.removeItem(atPath: path)
        }
    }
    // 删除沙盒指定文件夹内容
    class func deleteDirectory(path: String) {
        if isDirectoryExist(path: path) {
            // 获取该路径下面的文件名
            let childrenFiles = fileManager.subpaths(atPath: path )
            for fileName in childrenFiles ?? [] {
                deleteFile(path: URL(fileURLWithPath: path ).appendingPathComponent(fileName).absoluteString)
            }
        }
    }
    
    // 沙盒是否有指定路径文件夹或文件
    class func isDirectoryExist(path: String?) -> Bool {
        return fileManager.fileExists(atPath: path ?? "")
    }
    
    // 是否是文件夹
    class func isDirectory( path: String) -> Bool {
        
        var isDir: ObjCBool = ObjCBool(false)
        fileManager.fileExists(atPath: path , isDirectory: &isDir)
        return isDir.boolValue
    }
    
    /** 计算文件夹或者文件的大小 */
    class  func getFilePathSize(path: String)-> String
    {
        if path.count == 0 {
            return "0MB" as String
        }
        if !fileManager.fileExists(atPath: path){
            return "0MB" as String
        }
        var fileSize:Float = 0.0
        do {
            let files = try fileManager.contentsOfDirectory(atPath: path)
            for file in files {
                fileSize = fileSize + fileSizeAtPath(filePath: path + "/\(file)")
            }
        }catch{
            fileSize = fileSize + fileSizeAtPath(filePath: path)
        }
        var resultSize = ""
        if fileSize >= 1024.0*1024.0{
            resultSize = NSString(format: "%.2fMB", fileSize/(1024.0 * 1024.0)) as String
        }else if fileSize >= 1024.0{
            resultSize = NSString(format: "%.fkb", fileSize/(1024.0 )) as String
        }else{
            resultSize = NSString(format: "%llub", fileSize) as String
        }
        return resultSize
    }
    
    /**  计算单个文件或文件夹的大小 */
    class  func fileSizeAtPath(filePath:String) -> Float {
        var fileSize:Float = 0.0
        if fileManager.fileExists(atPath: filePath) {
            do {
                let attributes = try fileManager.attributesOfItem(atPath: filePath)
                
                if attributes.count != 0 {
                    
                    fileSize = attributes[FileAttributeKey.size]! as! Float
                }
            }catch{
                
            }
        }
        return fileSize;
    }
    
    //获取目录下所有文件和文件夹名字
    class func getDirectoryAllName(arguments: Any) -> [AnyHashable] {
        let path = arguments["path"] as! String
        var nameList: [AnyHashable] = []
        if !isDirectoryExist(path: path) {
            nameList.append("path not exist")
            return nameList
        }
        if !isDirectory(path: path) {
            nameList.append("path not exist")
            return nameList
        }
        let dirEnum = fileManager.enumerator(atPath: path )
        //列举目录内容，可以遍历子目录
        let name: String
        while (name == dirEnum?.nextObject() as? String )  {
            if self.isDirectoryExist(path: name) == true {
                dirEnum?.skipDescendants()
            }
            nameList.append(name)
        }
        return nameList
    }
    
    //解压文件
    class func unZipFile(filePath: String) -> String {
        if self.isDirectoryExist(path: filePath) {
            SSZipArchive.unzipFile(atPath: filePath, toDestination: (filePath as NSString).substring(to: (filePath.count ?? 0) - ((filePath.components(separatedBy: "/").last).count ?? 0)))
            return "Success"
        } else {
            return "NotFile"
        }
    }
    class func createFolder(folderName: NSString,folderPath: NSString) -> NSString {
        let path = "\(folderPath)/\(folderName)"
        // 不存在的路径才会创建
        if (!isDirectoryExist(path: path)) {
            //withIntermediateDirectories为ture表示路径中间如果有不存在的文件夹都会创建
            try! fileManager.createDirectory(atPath: path,withIntermediateDirectories: true, attributes: nil)
        }
        return path as NSString
    }
}
