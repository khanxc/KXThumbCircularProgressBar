
Pod::Spec.new do |s|


  s.name         = "KXThumbCircularProgressBar"
  s.version      = "0.0.2"
  s.summary      = "Circular progress bar with a customizable thumb pointer image"

  s.description  = "Circular progress bar with an image at the progress end which is customizable along with other features."

  s.homepage     = "http://www.appyte.com"

  s.license      = "MIT"

  s.author             = "Khan"


  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/khanxc/KXThumbCircularProgressBar.git", :tag => "0.0.2" }




  s.source_files  = "KXThumbCircularProgressBar", "KXThumbCircularProgressBar/**/*.{h,m,swift}"

  s.resources = "KXThumbCircularProgressBar/KXThumbCircularProgressView/*.png"


end
