#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint alilive_plugin.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'alilive_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin.'
  s.description      = <<-DESC
A new Flutter plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }

  s.ios.vendored_frameworks = 'AlivcLivePusherSDK/AlivcLibRtmp.framework','AlivcLivePusherSDK/AlivcLivePusher.framework','AlivcLivePusherSDK/AliThirdparty.framework','AlivcLivePusherSDK/AlivcLibFace.framework','AlivcLivePusherSDK/AlivcLibBeauty.framework','AlivcLivePusherSDK/AliyunPlayerSDK.framework'

  s.vendored_frameworks = 'AlivcLibRtmp.framework','AlivcLivePusher.framework','AliThirdparty.framework','AlivcLibFace.framework','AlivcLibBeauty.framework','AliyunPlayerSDK.framework'

  s.resources = ['AlivcLivePusherSDK/AlivcLibFaceResource.bundle','AlivcLivePusherSDK/AliyunLanguageSource.bundle','Classes/imgs/*.png']
  
  s.source_files = 'Classes/**/*'
  s.static_framework = true
  s.dependency 'Flutter'
  
#  s.dependency 'AlivcLivePusherWithPlayer'
#  s.dependency 'AlipaySDK-iOS', '~> 15.6.8'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
  

  
end
