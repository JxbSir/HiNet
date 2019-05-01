Pod::Spec.new do |s|

  s.name         = "HiNet"
  s.version      = "1.0"
  s.summary      = "HiNet, A lightweight http/https capture tool."
  s.description  = "HiNet, A lightweight http/https capture tool."
  s.homepage     = "https://github.com/JxbSir/HiNet.git"
  s.license      = { :type => "MIT" }
  s.author       = { "jinxuebin" => "i@jxb.name" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "git@github.com:JxbSir/HiNet.git", :tag => "#{s.version}" }

  s.source_files = "HiNet/Source/**/*.{h,m}"
  s.resources    = ["HiNet/Source/**/*.html", "HiNet/Source/**/*.js", "HiNet/Source/**/*.css"]
  s.requires_arc = true
  
  s.dependency 'GCDWebServer'

end
