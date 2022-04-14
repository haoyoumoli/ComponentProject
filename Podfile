workspace 'ComponentProject'

def common_pods
  # layout
  pod 'SnapKit'
  
  # image load
  pod 'SDWebImage'
end

abstract_target 'ComponentProject' do
  platform:ios, '10.0'
  use_frameworks!
  
  common_pods
  
  target 'MainProject' do
    project 'MainProject/MainProject.xcodeproj'
  end
  
  target 'HomeProject' do
    project 'HomeProject/HomeProject.xcodeproj'
    
    target 'HomeComponent' do
    end
  end
  
  
  target 'VideoPlayDemo' do
    project 'VideoPlayDemo/VideoPlayDemo.xcodeproj'
    pod 'PLPlayerKit'
    # video play
    pod 'JPVideoPlayer', '~> 3.1.1'
    
  end
  
  target 'BuglyDemo' do
    project 'BuglyDemo/BuglyDemo.xcodeproj'
  pod 'Bugly'
  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '7.10.2'
  
  # pod 'BuglyHotfix'
  end
  
  target 'Live' do
    project 'Live/Live.xcodeproj'
  common_pods
  
  #LFRtmp中包含了GPUImage
  #pod 'GPUImage'
  
  pod 'LFRtmp',:path => './LFRtmp'
  #pod 'LFLiveKit'
  end
  
end




