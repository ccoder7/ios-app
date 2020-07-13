install! 'cocoapods',
:generate_multiple_pod_projects => true,
:incremental_installation => true

platform :ios, '11.0'

def mixin_services
  pod 'libsignal-protocol-c', :git => 'https://github.com/wuyuehyang/libsignal-protocol-c.git'
  pod 'WCDB.swift', :git => 'https://github.com/MixinNetwork/wcdb.git', :branch => 'bugfix/fts'
  pod 'SwiftyMarkdown', :git => 'https://github.com/wuyuehyang/SwiftyMarkdown.git'
  pod 'MixinServices', :path => './MixinServices'
end

target 'Mixin' do
  use_frameworks!
  inhibit_all_warnings!

  pod 'Firebase/Core'
  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'
  pod 'Firebase/Crashlytics'
  pod 'GoogleMLKit/BarcodeScanning'
  pod 'GoogleMLKit/FaceDetection'
  pod 'SnapKit'
  pod 'PhoneNumberKit'
  pod 'RSKImageCropper'
  pod 'GoogleWebRTC'
  pod 'AlignedCollectionViewFlowLayout'
  pod 'R.swift'
  pod 'Highlightr', :git => 'https://github.com/wuyuehyang/Highlightr.git', :branch => 'master'
  pod 'Texture', :git => 'https://github.com/TextureGroup/Texture.git', :branch => 'master'
  pod 'TexturedMaaku', :git => 'https://github.com/wuyuehyang/TexturedMaaku.git', :branch => 'mixin'
  pod 'TexturedMaaku/SyntaxColors', :git => 'https://github.com/wuyuehyang/TexturedMaaku.git', :branch => 'mixin'
  mixin_services
end

target 'MixinNotificationService' do
  use_frameworks!
  inhibit_all_warnings!
  
  mixin_services
end

target 'MixinShare' do
  use_frameworks!
  inhibit_all_warnings!

  pod 'R.swift'
  mixin_services
end

