Pod::Spec.new do |s|
  s.name         = "Freezer"
  s.version      = "1.0.0"
  s.summary      = "Let your Swift tests travel through time"

  s.description  = <<-DESC
  Freezer is a library that allows your swift tests to travel through time by mocking NSDate class
                   DESC

  s.homepage     = "https://github.com/Pr0Ger/Freezer"

  s.license      = "MIT"

  s.author             = { "Sergey Petrov" => "me@pr0ger.org" }
  s.social_media_url   = "http://twitter.com/Pr0Ger"

  s.source       = { :git => "https://github.com/Pr0Ger/Freezer.git", :tag => "#{s.version}" }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files  = "freezer.swift"
end
