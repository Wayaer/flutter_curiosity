#import "NativeUtils.h"

@implementation NativeUtils

//Log
+ (void)log:(id)info{
    NSLog(@"Curiosity--- %@", info);
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

@end
