
Pod::Spec.new do |s|

  s.name         = "BWSegmentedControl"
  s.authors      = { 'Mendy Krinsky' => 'mendyk3@gmail.com' }
  s.version      = "0.0.1"
  s.summary      = "A segmented control with a ball indicator "
  s.license      =  { :type => 'MIT' }
  s.homepage     = "https://github.com/ralito/BWSegmentedControl"
  s.ios.deployment_target = '7.0'
  s.source       = { :git => "https://github.com/ralito/BWSegmentedControl.git", :commit => "e81157dbe68ef220a07dbad2b025a2f6fe5b583e" }
  s.source_files  = "Segmented Control/*.{h,m}"
end
