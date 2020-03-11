#import "CuriosityPlugin.h"
#if __has_include(<flutter_curiosity/curiosity-Swift.h>)
#import <curiosity/curiosity-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "curiosity-Swift.h"
#endif

@implementation CuriosityPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCuriosityPlugin registerWith:registrar];
}
@end
