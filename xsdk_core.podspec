Pod::Spec.new do |s|
    s.name             = 'xsdk_core'
    s.version          = '1.0.0'
    s.summary          = 'core of xsdk.'
    s.description      = <<-DESC
    core of xsdk.
                         DESC
  
    s.homepage         = 'https://github.com/x-sdk'
    s.license          = { :type => 'BSD'  }
    s.author           = { 'yuangu' => 'seantone@126.com' }
    s.source           = { :git => 'https://github.com/x-sdk/xsdk_ios_core.git', :tag => s.version.to_s }
    
    s.ios.deployment_target = '11.0'
    s.static_framework = true
    s.libraries    = 'stdc++'
    
    s.source_files  = "src/**/*"
    s.public_header_files = "src/**/**/*.h"
    
  end
  
