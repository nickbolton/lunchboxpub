source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'
use_frameworks!
inhibit_all_warnings!

target 'Lunchbox' do
  pod 'MobileKit/Animator', :path => '~/src/pixelbleed/mobilekit'
  pod 'MobileKit/Text', :path => '~/src/pixelbleed/mobilekit'
  pod 'Alamofire', '~> 4.7'
  pod 'AlamofireNetworkActivityIndicator', '~> 2.2'
  pod 'AlamofireNetworkActivityLogger', '~> 2.3'
  pod 'HTTPStatusCodes', '~> 3.2'
#  pod 'Firebase/Core'
#  pod 'Firebase/RemoteConfig'
  pod 'ReSwift', '~> 4.0'
  pod 'RxSwift', '~> 4.4'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'Gifu'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
        if target.name == 'Cache' || target.name == 'AlamofireNetworkActivityIndicator' || target.name == 'SnapKit' || target.name == 'Siesta'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        else 
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.2'
            end
        end
        # Cache pod does not accept optimization level '-O', causing Bus 10 error. Use '-Osize' or '-Onone'
        if target.name == 'Cache'
            target.build_configurations.each do |config|
                level = '-Osize'
                config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = level
                puts "Set #{target.name} #{config.name} to Optimization Level #{level}"
            end
        end
    end
end
