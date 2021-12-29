import FlutterMacOS
import Foundation

class FilePickerTools {
    static func openFilePicker(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let panel = NSOpenPanel()
        let arguments = call.arguments as! [String: Any?]

        // 是否能选择文件file
        panel.canChooseFiles = arguments["canChooseFiles"] as! Bool
        // 是否能打开文件夹
        panel.canChooseDirectories = arguments["canChooseDirectories"] as! Bool
        // 是否可以创建文件夹
        panel.canCreateDirectories = arguments["canCreateDirectories"] as! Bool
        // 指示面板是否解析别名
        panel.resolvesAliases = arguments["resolvesAliases"] as! Bool
        // 是否允许多选file
        panel.allowsMultipleSelection = arguments["allowsMultipleSelection"] as! Bool

        // 指示面板如何响应本地未完全下载的iCloud文档。
        panel.canDownloadUbiquitousContents = arguments["canDownloadUbiquitousContents"] as! Bool
        // 指示面板如何响应具有冲突版本的iCloud文档
        panel.canResolveUbiquitousConflicts = arguments["canResolveUbiquitousConflicts"] as! Bool
        setPanel(panel: panel, arguments: arguments)

        let isModal = arguments["isModal"] as! Bool
        if isModal {
            let finded = panel.runModal()
            if finded == .OK {
                // 点击了ok
                var fileUrl = [String]()
                for url in panel.urls {
                    fileUrl.append(url.path)
                }
                result(fileUrl)
                return
            } else if finded == .cancel {
                // 点了取消
            }
            result([])
        } else {
            panel.begin { response in
                if response == .OK {
                    // 点击了ok
                    var fileUrl = [String]()
                    for url in panel.urls {
                        fileUrl.append(url.path)
                    }
                    result(fileUrl)
                    return
                }
                result([])
            }
        }
    }

    static func saveFilePicker(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let panel = NSSavePanel()
        let arguments = call.arguments as! [String: Any?]

        setPanel(panel: panel, arguments: arguments)

        let isModal = arguments["isModal"] as! Bool
        if isModal {
            let finded = panel.runModal()
            if finded == .OK {
                // 点击了ok
                result(panel.url?.path)
                return
            } else if finded == .cancel {
                // 点了取消
            }
            result(nil)
        } else {
            panel.begin { response in
                if response == .OK {
                    result(panel.url?.path)
                    return
                }
                result(nil)
            }
        }
    }

    private static func setPanel(panel: NSSavePanel, arguments: [String: Any?]) {
        // 默认打开的路径
        panel.directoryURL = URL(string: arguments["directoryURL"] as! String)

        // 允许的文件类型 默认储存的文件后缀
        panel.allowedFileTypes = (arguments["allowedFileTypes"] as? [String])

        // 是否可以创建文件夹
        panel.canCreateDirectories = arguments["canCreateDirectories"] as! Bool

        // 是否显示隐藏文件
        panel.canSelectHiddenExtension = arguments["canSelectHiddenExtension"] as! Bool

        // 指示面板是否显示标签字段。
        panel.showsTagField = arguments["showsTagField"] as! Bool

        panel.isExtensionHidden = arguments["isExtensionHidden"] as! Bool

        // 默认的“打开”那两个字可以改变
        panel.prompt = (arguments["prompt"] as! String)

        // 面板显示的信息
        panel.message = (arguments["message"] as! String)

        // 面板标题
        panel.title = (arguments["title"] as! String)

        // 显示在文件名文本字段前面的标签文本。
        panel.nameFieldLabel = (arguments["nameFieldLabel"] as! String)

        // 默认储存的文件名
        panel.nameFieldStringValue = (arguments["nameFieldStringValue"] as! String)

        // 要包含在已保存文件中的标记名称
        panel.tagNames = (arguments["tagNames"] as! [String])
    }
}
