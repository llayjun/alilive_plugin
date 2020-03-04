#import "AlilivePlugin.h"
#import "ChannelTool.h"


#if __has_include(<alilive_plugin/alilive_plugin-Swift.h>)
#import <alilive_plugin/alilive_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "alilive_plugin-Swift.h"
#endif

@implementation AlilivePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAlilivePlugin registerWithRegistrar:registrar];
  [[ChannelTool sharedManager]flutterBridgeOC];
}
@end
