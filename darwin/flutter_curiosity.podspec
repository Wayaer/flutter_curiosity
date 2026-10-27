#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_curiosity.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_curiosity'
  s.version          = '8.0.0'
  s.summary          = 'Native features for Flutter apps on iOS and macOS.'
  s.description      = <<-DESC
Integrates native features for Flutter apps, including GPS status, keyboard status,
Installed apps, APK installation and media saving.
                       DESC
  s.homepage         = 'https://github.com/Wayaer/flutter_curiosity'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Wayaer' => 'https://github.com/Wayaer' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_curiosity/Sources/flutter_curiosity/**/*.swift'

  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'

  # Flutter.framework does not contain a i386 slice.
  s.ios.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.osx.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'

  # Bundle the privacy manifest with the plugin.
  s.resource_bundles = { 'flutter_curiosity_privacy' => ['flutter_curiosity/Sources/flutter_curiosity/PrivacyInfo.xcprivacy'] }
end
