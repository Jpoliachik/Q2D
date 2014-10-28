
Pod::Spec.new do |s|

  s.name         = "Q2D"
  s.version      = "0.0.1"
  s.summary      = "A two-dimensional NSOperationQueue built for easy reordering"

  s.description  = <<-DESC
                   A longer description of Q2D in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/Jpoliachik/Q2D"
  s.license      = "Apache"
  s.author             = { "Justin Poliachik" => "jpoliachik@gmail.com" }

  s.platform     = :ios
  s.ios.deployment_target = "5.0"

  s.source       = { :git => "https://github.com/Jpoliachik/Q2D.git", :tag => "0.0.1" }
  s.source_files  = "Q2D"
  s.requires_arc = true
end
