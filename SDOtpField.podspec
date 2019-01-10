#
# Be sure to run `pod lib lint SDOtpField.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SDOtpField'
  s.version          = '1.0.0'
  s.summary          = 'SDOtpField is a segmented text field with limited number of input characters.'
  s.swift_version    = '4.2'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
SDOtpField is a segmented text field with limited number of input characters.
SDOtpField allows user to enter only one character in each filed just like views used used in most of the apps to verify OTP.
DESC

  s.homepage         = 'https://github.com/sandeep-chhabra/SDOtpField'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sandeep-chhabra' => 'sandeepchhabra.90@live.com' }
  s.source           = { :git => 'https://github.com/sandeep-chhabra/SDOtpField.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SDOtpField/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SDOtpField' => ['SDOtpField/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
