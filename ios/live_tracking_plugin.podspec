#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint live_tracking_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'live_tracking_plugin'
  s.version          = '0.1.0'
  s.summary          = 'A comprehensive live tracking package for Flutter with offline support.'
  s.description      = <<-DESC
A comprehensive live tracking package for Flutter with offline support, high accuracy GPS tracking, 
and real-time synchronization. Compatible with iOS and Android. Features include real-time GPS tracking, 
activity recording, offline storage with SQLite, and automatic synchronization with backend APIs.
                       DESC
  s.homepage         = 'https://github.com/yourusername/live_tracking_plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # Privacy manifest for location services
  s.resource_bundles = {'live_tracking_plugin_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
