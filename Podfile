# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'SafeMapp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'IQKeyboardManagerSwift', '~> 6.4'
  pod 'Firebase/Core', '~> 6.15.0'
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'MBProgressHUD', '~> 1.1.0'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.2'
    end
  end
end