# Set platform target
platform :ios, '12.0'

# Ignore warnings from all pods
inhibit_all_warnings!

def link_pods
  # Enable dynamic frameworks
  use_frameworks!

  # Firebase
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Messaging'

end

target 'CouchClub' do
  link_pods
end

target 'CouchClub Staging' do
  link_pods
end

target 'CouchClubTests' do
  inherit! :search_paths
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
