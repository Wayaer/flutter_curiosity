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

NSString* getWifiIP() {
  NSString* address = @"error";
  struct ifaddrs* interfaces = NULL;
  struct ifaddrs* temp_addr = NULL;
  int success = 0;

  // Retrieve the current interfaces - returns 0 on success.
  success = getifaddrs(&interfaces);
  if (success == 0) {
    // Loop through linked list of interfaces.
    temp_addr = interfaces;
    while (temp_addr != NULL) {
      if (temp_addr->ifa_addr->sa_family == AF_INET) {
        // Check if interface is en0 which is the wifi connection on the iPhone.
        if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
          // Get NSString from C String
          address = [NSString
              stringWithUTF8String:inet_ntoa(((struct sockaddr_in*)temp_addr->ifa_addr)->sin_addr)];
        }
      }

      temp_addr = temp_addr->ifa_next;
    }
  }

  // Free memory
  freeifaddrs(interfaces);

  return address;
}


@end
