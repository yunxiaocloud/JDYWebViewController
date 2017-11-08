#
# Be sure to run `pod lib lint JDYWebViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JDYWebViewController'
  s.version          = '1.0.2'
  s.summary          = '封装的一个简单易用的WebView.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'http://yuncloud.xyz/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '15522613388@163.com' => 'xue.jingjin@9douyu.com' }
  s.source           = { :git => 'https://github.com/yunxiaocloud/JDYWebViewController.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'JDYWebViewController/Classes/**/*'
  s.public_header_files = 'JDYWebViewController/Classes/**/*.h'
  s.frameworks = 'UIKit', 'MapKit'
end
