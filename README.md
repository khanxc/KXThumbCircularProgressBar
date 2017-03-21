# KXThumbCircularProgressBar
A Circular progress bar with a progress thumb(icon) written in pure Swift.
Customise your own thumb images to the Circular progress bar.


![Alt Text](https://github.com/khanxc/KXThumbCircularProgressBar/blob/master/Example/KXThumbCircular-Example/KXThumbCircular-Example/gifs/feature1.gif)


![Alt Text](https://github.com/khanxc/KXThumbCircularProgressBar/blob/master/Example/KXThumbCircular-Example/KXThumbCircular-Example/gifs/feature2.gif)

![Alt Text](https://github.com/khanxc/KXThumbCircularProgressBar/blob/master/Example/KXThumbCircular-Example/KXThumbCircular-Example/gifs/feature3.gif)

# Features
- [x] Customise thumb images
- [x] Increase/decrease the width of inner/outer ring
- [x] Customize inner/outer ring colors
- [x] Add Image / Text (with unit of measurement) at the centre

# Requirements
- iOS 8.0+
- Xcode 7.3

# Installation
## Cocoapods
You can use [CocoaPods](http://cocoapods.org/pods/KXThumbCircularProgressBar) to install *KXThumbCircularProgressBar* by adding it to your podfile

```
pod 'KXThumbCircularProgressBar', '~> 0.0.4'
```
And import the header and use it in the ViewController where you use this framework

```swift 
  import KXThumbCircularProgressBar
  
  @IBOutlet weak var kx: KXThumbCircularProgressBar!

  override func viewDidLoad() {
        super.viewDidLoad()
        kx.animateScale = 0.75 //value between 0 to 1
    } 
```

# License
Distributed under MIT license. Please see [LICENSE](https://github.com/khanxc/KXThumbCircularProgressBar/blob/master/LICENSE.md) file.

  
  
