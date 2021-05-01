
platform :ios, '11.0'
use_frameworks!
inhibit_all_warnings!

def kakao_sdk_modules
  pod 'KakaoSDKCommon'
  pod 'KakaoSDKAuth'
  pod 'KakaoSDKUser'
end

workspace 'Clean-Mooyaho-Codebase'

target 'MooyahoApp' do
  project 'MooyahoApp/MooyahoApp.xcodeproj'
  
  kakao_sdk_modules
    
  target 'MooyahoAppTests' do
      inherit! :search_paths
  end
end