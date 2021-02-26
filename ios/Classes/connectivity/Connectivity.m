#import "Tools.h"
#import "Connectivity.h"
#import "Reachability/Reachability.h"

@implementation Connectivity{
    FlutterEventSink _eventSink;
    Reachability* _reachability;
}

- (void)onReachabilityDidChange:(NSNotification*)notification {
    Reachability* curReach = [notification object];
    _eventSink([Tools getNetworkStatus:curReach]);
}

#pragma mark FlutterStreamHandler impl

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _eventSink = eventSink;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onReachabilityDidChange:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    _reachability = [Reachability reachabilityForInternetConnection];
    [_reachability startNotifier];
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    if (_reachability) {
        [_reachability stopNotifier];
        _reachability = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _eventSink = nil;
    return nil;
}

@end
