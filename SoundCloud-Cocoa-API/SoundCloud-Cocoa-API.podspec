Pod::Spec.new do |s|
  	s.name = 'SoundCloud-Cocoa-API'
    s.module_name = 'SoundCloud'
  	s.summary = 'Maintained version of the Soundcloud Cocoa API.'
  	s.version = '1.1.2'
  	s.license = { :type => 'Proprietary', :text => 'https://developers.soundcloud.com/docs/api/terms-of-use' }
  	s.author = 'SoundCloud'
  	s.homepage = 'https://developers.soundcloud.com/docs/api/ios-quickstart'

  	s.source = { :git => 'https://github.com/mhuusko5/SoundCloud-Cocoa-API.git', :tag => s.version.to_s }

  	s.ios.deployment_target = '7.0'
  	s.osx.deployment_target = '10.8'
    s.tvos.deployment_target = '9.0'

  	s.source_files = 'Sources', 'Sources/**/*.{h,m}'

  	s.framework = 'Security'
  	s.dependency 'NXOAuth2Client', '~> 1.2.2'

  	s.requires_arc = true
end
