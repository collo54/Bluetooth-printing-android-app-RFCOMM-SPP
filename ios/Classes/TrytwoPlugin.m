#import "TrytwoPlugin.h"
#if __has_include(<trytwo/trytwo-Swift.h>)
#import <trytwo/trytwo-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "trytwo-Swift.h"
#endif

@implementation TrytwoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTrytwoPlugin registerWithRegistrar:registrar];
}
@end
