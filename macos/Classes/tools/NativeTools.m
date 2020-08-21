#import "NativeTools.h"
#import <CoreLocation/CoreLocation.h>
#define fileManager [NSFileManager defaultManager]

@implementation NativeTools

//跳转到AppStore
+ (void)goToMarket:(NSString *)props{
    NSString* url=@"itms-apps://itunes.apple.com/us/app/id";
    //    [[NSApplication sharedApplication] openURL:[NSURL URLWithString:[url stringByAppendingString:props]]];
}

+ (void)callPhone:(NSString *)phoneNumber {
    //    [[NSApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:://" stringByAppendingString:phoneNumber]]];
}
+ (NSMutableDictionary *)getAppInfo
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    NSDictionary *app = [[NSBundle mainBundle] infoDictionary];
    //    CGRect statusBar = [[NSApplication sharedApplication] statusBarFrame];
    //    [info setObject:@(statusBar.size.height) forKey:@"statusBarHeight"];
    //    [info setObject:@(statusBar.size.width) forKey:@"statusBarWidth"];
    
    [info setObject:NSHomeDirectory() forKey:@"homeDirectory"];
    [info setObject:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] forKey:@"documentDirectory"];
    [info setObject:[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] forKey:@"libraryDirectory"];
    [info setObject:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] forKey:@"cachesDirectory"];
    [info setObject:NSTemporaryDirectory() forKey:@"temporaryDirectory"];
    
    [info setObject:[app objectForKey:@"CFBundleShortVersionString"] forKey:@"versionName"];
    [info setObject:@"Apple" forKey:@"phoneBrand"];
    [info setObject:[NSNumber numberWithInt:[[app objectForKey:@"CFBundleVersion"] intValue]] forKey:@"versionCode"];
    
    [info setObject:[app objectForKey:@"CFBundleIdentifier"] forKey:@"packageName"];
    [info setObject:[app objectForKey:@"CFBundleName"] forKey:@"appName"];
    [info setObject:[app objectForKey:@"DTSDKBuild"] forKey:@"sdkBuild"];
    //    [info setObject:[app objectForKey:@"DTPlatformName"] forKey:@"platformName"];
    //    [info setObject:[app objectForKey:@"MinimumOSVersion"] forKey:@"minimumOSVersion"];
    [info setObject:[app objectForKey:@"DTPlatformVersion"] forKey:@"platformVersion"];
    //    GDevice *device = [device currentDevice];
    //    [info setObject:device->systemName forKey:@"systemName"];
    //    [info setObject:device->systemVersion forKey:@"systemVersion"];
    return info;
}


//获取目录文件或文件夹大小
+ (NSString *)getFilePathSize:(NSString *)path{
    // 获取“path”文件夹下的所有文件
    NSArray *subPathArr = [[NSFileManager defaultManager] subpathsAtPath:path];
    NSString *filePath  = nil;
    NSInteger totalSize = 0;
    for (NSString *subPath in subPathArr){
        // 1. 拼接每一个文件的全路径
        filePath =[path stringByAppendingPathComponent:subPath];
        // 2. 是否是文件夹，默认不是
        BOOL isDirectory = [Tools isDirectory:path];
        // 3. 判断文件是否存在
        BOOL isExist = [Tools isDirectoryExist:path];
        // 4. 以上判断目的是忽略不需要计算的文件
        if (!isExist || isDirectory || [filePath containsString:@".DS"]){
            // 过滤: 1. 文件夹不存在  2. 过滤文件夹  3. 隐藏文件
            continue;
        }
        // 5. 指定路径，获取这个路径的属性
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        /**
         attributesOfItemAtPath: 文件夹路径
         该方法只能获取文件的属性, 无法获取文件夹属性, 所以也是需要遍历文件夹的每一个文件的原因
         */
        // 6. 获取每一个文件的大小
        NSInteger size = [dict[@"NSFileSize"] integerValue];
        // 7. 计算总大小
        totalSize += size;
    }
    //8. 将文件夹大小转换为 M/KB/B
    NSString *totalStr = nil;
    if (totalSize > 1000 * 1000){
        totalStr = [NSString stringWithFormat:@"%.2fMB",totalSize / 1000.00f /1000.00f];
        
    }else if (totalSize > 1000){
        totalStr = [NSString stringWithFormat:@"%.2fKB",totalSize / 1000.00f ];
        
    }else{
        totalStr = [NSString stringWithFormat:@"%.2fB",totalSize / 1.00f];
    }
    return totalStr;
}
+(void)openImagePicker:(FlutterMethodCall*)call result:(FlutterResult)result{
    //    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    //    [openPanel setPrompt: @"打开"];
    //
    //    openPanel.allowedFileTypes = [NSArray arrayWithObjects: @"txt", @"doc", nil];
    //    openPanel.directoryURL = nil;
    //
    //    [openPanel beginSheetModalForWindow:[self gainMainViewController] completionHandler:^(NSModalResponse returnCode) {
    //
    //        if (returnCode == 1) {
    //            NSURL *fileUrl = [[openPanel URLs] objectAtIndex:0];
    //            // 获取文件内容
    //            NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingFromURL:fileUrl error:nil];
    //            NSString *fileContext = [[NSString alloc] initWithData:fileHandle.readDataToEndOfFile encoding:NSUTF8StringEncoding];
    //
    //            // 将 获取的数据传递给 ViewController 的 TextView
    //            ViewController *mainViewController = (ViewController *)[self gainMainViewController].contentViewController;
    //            mainViewController.showCodeTextView.string = fileContext;
    //        }
    //    }];
    
}
//判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
+ (BOOL) getGPSStatus {
    return [CLLocationManager locationServicesEnabled];
}

@end
