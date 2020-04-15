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

+ (void)callPhone:(NSString *)phoneNumber :(NSNumber*)directDial {
    
    if ([directDial intValue]==1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:://" stringByAppendingString:phoneNumber]]];
    }else{
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:phoneNumber] ]]];
        [[UIApplication sharedApplication].keyWindow addSubview:callWebview];
    }
    
}

@end
