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
+ (void)callPhone:(NSString *)phoneNumber :(NSNumber*)directDial {
    
    if ([directDial intValue]==1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:://" stringByAppendingString:phoneNumber]]];
    }else{
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:phoneNumber] ]]];
        [[UIApplication sharedApplication].keyWindow addSubview:callWebview];
    }
    
}
+ (void)setStatusBarColor:(NSNumber*)fontIconDark :(NSString *)statusBarColor {
    if (@available(iOS 13.0, *)) {
        UIView *statusBar = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame];
        statusBar.backgroundColor = [NativeUtils colorWithHexString:statusBarColor];
        [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
    }else{
        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
            statusBar.backgroundColor = [NativeUtils colorWithHexString:statusBarColor];
        }  }
    if([fontIconDark intValue]==1){
        [UIApplication sharedApplication].statusBarStyle =  UIStatusBarStyleDefault;
    }else{
        [UIApplication sharedApplication].statusBarStyle =  UIStatusBarStyleLightContent;
    }
    
}
/**
 16进制颜色转换为UIColor
 @param hexColor 16进制字符串（可以以0x开头，可以以#开头，也可以就是6位的16进制）
 @return 16进制字符串对应的颜色
 */

+(UIColor *)colorWithHexString:(NSString *)hexColor{
    NSString * cString = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor blackColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6&[cString length] != 8) return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString * rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString * gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString * bString = [cString substringWithRange:range];
    
    NSString * aString=@"10";
    if ([cString length]==8) {
        range.location = 6;
        aString = [cString substringWithRange:range];
    }
    // Scan values
    unsigned int r, g, b, a;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    a=[aString intValue];
    return [UIColor colorWithRed:((float)r / 255.0f)
                           green:((float)g / 255.0f)
                            blue:((float)b / 255.0f)
                           alpha:(((float)a/10)/ 1.0f)];
}


@end
