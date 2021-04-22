#import "NativeTools.h"
#import "Tools.h"
#import <CoreLocation/CoreLocation.h>
#define fileManager [NSFileManager defaultManager]
#import <sys/utsname.h>

@implementation NativeTools


+ (void)callPhone:(NSString *)phoneNumber {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:://" stringByAppendingString:phoneNumber]]];
}

+ (NSDictionary *)getDeviceInfo{
    UIDevice* device = [UIDevice currentDevice];
    struct utsname un;
    uname(&un);
    return(@{
        @"name" : [device name],
        @"systemName" : [device systemName],
        @"systemVersion" : [device systemVersion],
        @"model" : [device model],
        @"uuid" : [device identifierForVendor].UUIDString,
        @"localizedModel" : [device localizedModel],
        @"isEmulator" : [NSNumber numberWithBool:[Tools isEmulator]?YES:NO],
        @"uts" : @{
                @"sysName" : @(un.sysname),
                @"nodeName" : @(un.nodename),
                @"release" : @(un.release),
                @"version" : @(un.version),
                @"machine" : @(un.machine)}
           });
    
}


+ (NSDictionary *)getAppInfo{
    NSDictionary *app = [[NSBundle mainBundle] infoDictionary];
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    return(@{
        @"statusBarHeight" : @(statusBar.size.height),
        @"statusBarWidth" : @(statusBar.size.width),
        @"homeDirectory" : NSHomeDirectory(),
        @"documentDirectory" : [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject],
        @"libraryDirectory" :[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject],
        @"cachesDirectory" : [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject],
        @"temporaryDirectory" :NSTemporaryDirectory(),
        @"versionName" : [app objectForKey:@"CFBundleShortVersionString"],
        @"versionCode" : [NSNumber numberWithInt:[[app objectForKey:@"CFBundleVersion"] intValue]],
        @"packageName" : [app objectForKey:@"CFBundleIdentifier"],
        @"appName" : [app objectForKey:@"CFBundleName"],
        @"sdkBuild" : [app objectForKey:@"DTSDKBuild"],
        @"platformName" : [app objectForKey:@"DTPlatformName"] ,
        @"minimumOSVersion" : [app objectForKey:@"MinimumOSVersion"],
        @"platformVersion" : [app objectForKey:@"DTPlatformVersion"],
           });
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


/**
 *  分享
 *  多图分享，items里面直接放图片
 *  分享链接
 *  NSString *text = @"mq分享";
 *  UIImage *image = [UIImage imageNamed:@"imageName"];
 *  NSURL *url = [NSURL URLWithString:@"https:www.baidu.com"];
 *  NSArray *items = @[urlToShare,textToShare,imageToShare];
 */
+ (void)systemShare:(FlutterMethodCall*)call result:(FlutterResult)result{
    //    NSString * title=[call.arguments valueForKey:@"title"];
    NSString * content=[call.arguments valueForKey:@"content"];
    NSString * type=[call.arguments valueForKey:@"type"];
    NSArray * imagesPath=[call.arguments valueForKey:@"imagesPath"];
    NSMutableArray *items=[NSMutableArray array];
    if([type isEqual: @"images"]){
        if(imagesPath!=nil){
            for(NSString *value in imagesPath){
                UIImage *image = [UIImage imageNamed:value];
                [items addObject:image];
            }
        }else{
            result([Tools resultInfo:@"imagesPath is null"]);
        }
    }else{
        if(content!=nil){
            if([type isEqual: @"text"])[items addObject:content];
            if([type isEqual: @"url"])[items addObject:[NSURL URLWithString:content]];
            if([type isEqual: @"image"])[items addObject:[UIImage imageNamed:content]];
        }else{
            result([Tools resultInfo:@"content is null"]);
            return;
        }
    }
    
    if (0 == items.count) {
        result([Tools resultInfo:[@"not find " stringByAppendingString:type]]);
        return;
    }
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    if (@available(iOS 11.0, *)) {
        //UIActivityTypeMarkupAsPDF是在iOS 11.0 之后才有的
        activityVC.excludedActivityTypes = @[UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypeOpenInIBooks, UIActivityTypeMarkupAsPDF];
    }else if (@available(iOS 9.0, *)){
        //UIActivityTypeOpenInIBooks是在iOS 9.0 之后才有的
        activityVC.excludedActivityTypes = @[UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypeOpenInIBooks];
    }else{
        activityVC.excludedActivityTypes = @[UIActivityTypeMessage, UIActivityTypeMail];
    }
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        result(completed?[Tools resultSuccess]:[Tools resultFail]);
    };
    //这儿一定要做iPhone与iPad的判断，因为这儿只有iPhone可以present，iPad需pop，所以这儿actVC.popoverPresentationController.sourceView = self.view;在iPad下必须有，不然iPad会crash，self.view你可以换成任何view，你可以理解为弹出的窗需要找个依托。
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        activityVC.popoverPresentationController.sourceView = vc.view;
        [vc presentViewController:activityVC animated:YES completion:nil];
    }else{
        [vc presentViewController:activityVC animated:YES completion:nil];
    }
}


//跳转到设置页面让用户自己手动开启
+ (BOOL) jumpAppSetting {
    NSURL *url = [[NSURL alloc] initWithString:UIApplicationOpenSettingsURLString];
    if( [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
        return YES;
    }
    return NO;
}
//判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的
+ (BOOL) getGPSStatus {
    return [CLLocationManager locationServicesEnabled];
}

@end
