
Pod::Spec.new do |s|
  s.name             = 'SwiftTurf'
  s.version          = '0.2.5'
  s.summary          = 'SwiftTurf is Swift wrapper of the TurfJS library. http://turfjs.org'
  s.description      = <<-DESC
SwiftTurf is Swift wrapper of the TurfJS library. More information can be found at http://turfjs.org.
                       DESC

  s.homepage         = 'https://github.com/AirMap/SwiftTurf'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Adolfo Martinelli' => 'adolfo@airmap.com' }
  s.source           = { :git => 'https://github.com/AirMap/SwiftTurf.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'

  s.source_files = 'SwiftTurf/Classes/**/*'
  s.resources = 'SwiftTurf/Assets/js/dist/bundle.js'

end
