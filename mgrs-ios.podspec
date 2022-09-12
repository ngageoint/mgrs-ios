Pod::Spec.new do |s|
  s.name             = 'mgrs-ios'
  s.version          = '1.0.3'
  s.license          =  {:type => 'MIT', :file => 'LICENSE' }
  s.summary          = 'iOS SDK for Military Grid Reference System (MGRS)'
  s.homepage         = 'https://github.com/ngageoint/mgrs-ios'
  s.authors          = { 'NGA' => '', 'BIT Systems' => '', 'Brian Osborn' => 'bosborn@caci.com' }
  s.social_media_url = 'https://twitter.com/NGA_GEOINT'
  s.source           = { :git => 'https://github.com/ngageoint/mgrs-ios.git', :tag => s.version }
  s.requires_arc     = true

  s.platform         = :ios, '12.0'
  s.ios.deployment_target = '12.0'

  s.source_files = 'mgrs-ios/**/*.swift'

  s.resource_bundle = { 'mgrs-ios' => ['mgrs-ios/**/mgrs*.plist'] }
  s.frameworks = 'Foundation'

  s.dependency 'grid-ios', '~> 1.0.1'
end
