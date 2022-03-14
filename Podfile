workspace 'ComponentProject'

def common_pods
  # layout
  pod 'SnapKit'
  
  # video play
  pod 'JPVideoPlayer', '~> 3.1.1'
  
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

  end
  
end




