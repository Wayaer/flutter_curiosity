
#import "NativeUtils.h"

#define fileManager [NSFileManager defaultManager]
#define cachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]


@implementation NativeUtils


//Log
+ (void)log:(id)info{
    NSLog(@"LogInfo==> %@", info);
}

//跳转到AppStore
+ (void)goToMarket:(NSString *)props
{
    NSString* url=@"itms-apps://itunes.apple.com/us/app/id";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[url stringByAppendingString:props]]];
}


//cookie的设置 清除 获取
+ (void)setCookie:(NSDictionary *)props
{
    
    NSString *name = [props objectForKey:@"name"];
    NSString *value = [props objectForKey:@"value"];
    NSString *domain = [props objectForKey:@"domain"];
    NSString *origin = [props objectForKey:@"origin"];
    NSString *path = [props objectForKey:@"path"];
    NSDate *expiration = [props objectForKey:@"expiration"];
    //    NSString *name = [RCTConvert NSString:props[@"name"]];
    //    NSString *value = [RCTConvert NSString:props[@"value"]];
    //    NSString *domain = [RCTConvert NSString:props[@"domain"]];
    //    NSString *origin = [RCTConvert NSString:props[@"origin"]];
    //    NSString *path = [RCTConvert NSString:props[@"path"]];
    //    NSDate *expiration = [RCTConvert NSDate:props[@"expiration"]];
    
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:name forKey:NSHTTPCookieName];
    [cookieProperties setObject:value forKey:NSHTTPCookieValue];
    [cookieProperties setObject:domain forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:origin forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:path forKey:NSHTTPCookiePath];
    [cookieProperties setObject:expiration forKey:NSHTTPCookieExpires];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
}
+ (void)clearAllCookie
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *c in cookieStorage.cookies) {
        [cookieStorage deleteCookie:c];
    }
}
+ (NSMutableDictionary *)getAllCookie
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableDictionary *cookies = [NSMutableDictionary dictionary];
    for (NSHTTPCookie *c in cookieStorage.cookies) {
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        [d setObject:c.value forKey:@"value"];
        [d setObject:c.name forKey:@"name"];
        [d setObject:c.domain forKey:@"domain"];
        [d setObject:c.path forKey:@"path"];
        [cookies setObject:d forKey:c.name];
    }
    return cookies;
    
}

// 删除沙盒指定文件或文件夹
+ (void)deleteFile:(NSString *)path{
    if ([self isFolderExists:path]) {
        if(![fileManager removeItemAtPath:path error:nil]){
            [fileManager removeItemAtPath:path error:nil];
        }
    }
}
// 删除沙盒指定文件夹内容
+ (void)deleteFolder:(NSString *)path{
    if ([self isFolderExists:path]) {
        if ([fileManager fileExistsAtPath:path]) {
            // 获取该路径下面的文件名
            NSArray *childrenFiles = [fileManager subpathsAtPath:path];
            for (NSString *fileName in childrenFiles) {
                // 拼接路径
                NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
                // 将文件删除
                [fileManager removeItemAtPath:absolutePath error:nil];
            }
        }
    }
}
// 沙盒是否有指定路径文件夹或文件
+(BOOL)isFolderExists:(NSString *)path {
    if ([fileManager fileExistsAtPath:path]) {
        return YES;
    }else{
        return NO;
    }
}


//获取目录文件或文件夹大小
+ (NSString *)getFilePathSize:(NSString *)path{
    // 获取“path”文件夹下的所有文件
    NSArray *subPathArr = [[NSFileManager defaultManager] subpathsAtPath:path];
    NSString *filePath  = nil;
    NSInteger totleSize = 0;
    for (NSString *subPath in subPathArr){
        // 1. 拼接每一个文件的全路径
        filePath =[path stringByAppendingPathComponent:subPath];
        // 2. 是否是文件夹，默认不是
        BOOL isDirectory = NO;
        // 3. 判断文件是否存在
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        
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
        totleSize += size;
    }
    //8. 将文件夹大小转换为 M/KB/B
    NSString *totleStr = nil;
    if (totleSize > 1000 * 1000){
        totleStr = [NSString stringWithFormat:@"%.2fMB",totleSize / 1000.00f /1000.00f];
        
    }else if (totleSize > 1000){
        totleStr = [NSString stringWithFormat:@"%.2fKB",totleSize / 1000.00f ];
        
    }else{
        totleStr = [NSString stringWithFormat:@"%.2fB",totleSize / 1.00f];
    }
    return totleStr;
}


@end
