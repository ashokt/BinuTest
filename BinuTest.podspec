Pod::Spec.new do |spec|

  spec.name         = "BinuTest"
  spec.version      = "0.0.4"
  spec.summary      = "A Binu Test repository "

  spec.description  = <<-DESC
This CocoaPods library helps you perform Binu Proxy.
                   DESC

  spec.homepage     = "https://github.com/ashokt/BinuTest"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "ashokt" => "ashok@xminds.in" }

  spec.ios.deployment_target = "12.0"
  spec.swift_version = "5.0"

  spec.source        = { :git => "https://github.com/ashokt/BinuTest.git", :tag => "#{spec.version}" }
  spec.source_files  = "Binu/*.{h,m,swift}"
  spec.dependency 'Alamofire'
  spec.dependency 'MatomoTracker'

end
