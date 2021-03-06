
Pod::Spec.new do |s|

  s.name         = "Q2D"
  s.version      = "0.2.1"
  s.summary      = "A two-dimensional queue for NSOperations built for easy reordering"

  s.homepage     = "https://github.com/Jpoliachik/Q2D"
  s.license      = "Apache"
  s.author             = { "Justin Poliachik" => "jpoliachik@gmail.com" }

  s.platform     = :ios
  s.ios.deployment_target = "5.0"

  s.source       = { :git => "https://github.com/Jpoliachik/Q2D.git", :tag => "0.2.1" }
  s.source_files  = "Q2D"
  s.requires_arc = true
end
