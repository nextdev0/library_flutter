#import "NextstoryPlugin.h"
#if __has_include(<nextstory/nextstory-Swift.h>)
#import <nextstory/nextstory-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "nextstory-Swift.h"
#endif

@implementation NextstoryPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNextstoryPlugin registerWithRegistrar:registrar];
}
@end
