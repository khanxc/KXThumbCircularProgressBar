


//  Created by khan


import Foundation
import UIKit

//optional notification protocols

@objc public protocol KXArcNotifyDelegate {
    
    @objc optional func arcAnimationDidStart()
    @objc optional func arcAnimationDidStop()
}

// Nothing to see here , it is just a Pi

let π: CGFloat = CGFloat(M_PI)

// convenicence inits

extension KXThumbCircularProgressBar {
    
    public convenience init(ringWidth: CGFloat, ringHeight: CGFloat) {
        
        self.init(ringWidth: ringWidth, ringHeight: ringHeight,backgroundColor: UIColor.clear, ringBackgroundColour: UIColor(netHex: 0xaba8a8),  ringForegroundColour: UIColor.green, foreGroundArcWidth: 20, backGroundArcWidth: 8, arcStartAngle: 120, arcEndAngle: 60, arcMargin: 75)
    }
    
    public convenience init(ringWidth: CGFloat, ringHeight: CGFloat, backgroundColor: UIColor, ringBackgroundColour: UIColor, ringForegroundColour: UIColor) {
        
        self.init(ringWidth: ringWidth, ringHeight: ringHeight, backgroundColor: backgroundColor, ringBackgroundColour: ringBackgroundColour,  ringForegroundColour: ringForegroundColour, foreGroundArcWidth: 20, backGroundArcWidth: 8, arcStartAngle: 120, arcEndAngle: 60, arcMargin: 75)
    }
    
    
    public convenience init(ringWidth: CGFloat, ringHeight: CGFloat,arcStartAngle: CGFloat, arcEndAngle: CGFloat, arcMargin: CGFloat) {
        
        self.init(ringWidth: ringWidth, ringHeight: ringHeight,backgroundColor: UIColor.clear, ringBackgroundColour: UIColor(netHex: 0xaba8a8),  ringForegroundColour: UIColor.green, foreGroundArcWidth: 20, backGroundArcWidth: 8, arcStartAngle: arcStartAngle, arcEndAngle: arcEndAngle, arcMargin: arcMargin)
    }
}

//Designable core code

@IBDesignable public class KXThumbCircularProgressBar: UIView {
    
    // ring background properties
    
    @IBInspectable public var ringBackgroundColour: UIColor = UIColor(netHex: 0xaba8a8)
    @IBInspectable public var ringForegroundColour: UIColor = UIColor.green
    
    //This part is still under testing
    
    //	@IBInspectable public var backgroundImage: UIImage?
    
    //commented for next release feature
    //   @IBInspectable var lowLevelColor: UIColor        = UIColor.red
    //   @IBInspectable var midLevelColor: UIColor        = UIColor.orange
    //   @IBInspectable var highLevelColor: UIColor       = UIColor.green
    
    // must be between [0,100]
    
    //ring animate scale property
    
    @IBInspectable public var animateScale: Double = 0.0
    
    //width of the rings
    
    @IBInspectable public var foreGroundArcWidth: CGFloat   = 20
    @IBInspectable public var backGroundArcWidth: CGFloat   = 8
    
    
    // turn this on to show image at the arc leading tip
    
    @IBInspectable public var isthumbImageAvailable: Bool = false
    @IBInspectable public var thumbImage: UIImage?
    
    // set the start and end engle here
    
    @IBInspectable public var arcStartAngle: CGFloat = 120
    @IBInspectable public var arcEndAngle: CGFloat = 60
    @IBInspectable public var arcMargin: CGFloat = 75
    
    // turn this on to display  Image or Text at the center
    @IBInspectable public var showImage: Bool = false
    @IBInspectable public var image: UIImage?
    @IBInspectable public var showText: Bool = false
    @IBInspectable public var valueFontName: String = "HelveticaNeue"
    @IBInspectable public var valueFontSize: CGFloat = 25.0
    @IBInspectable public var showUnit: Bool = false
    @IBInspectable public var UnitString: String = "%"
    @IBInspectable public var unitFontName: String = "HelveticaNeue"
    @IBInspectable public var unitFontSize: CGFloat = 15.0
    @IBInspectable public var fontColor: UIColor = UIColor.black
    @IBInspectable public var valueMultiplier: Double = 100
    
    
    private let ringLayer = CAShapeLayer()
    private let thumbLayer = CALayer()
    private let imgView = UIImageView()
    private var thumbImageView = UIImageView()
    private var arcPath = UIBezierPath()
    private let textLabel = UILabel()
    
    // Arc animation notify Delegate
    public var delegate: KXArcNotifyDelegate?

    // TextAnimation
    private var start: Float = 0.0
    private var end: Float = 0.0
    private var timer: Timer?
    private var progress: TimeInterval!
    private var lastUpdate: TimeInterval!
    private var duration: TimeInterval!
    private var countingType: Float!
    private var animationType: UIViewAnimationCurve!
    private let kCounterRate: Float = 3.0

    private var currentValue: Float {
        if (progress >= duration) {
            return end
        }
        let percent = Float(progress / duration)
        let update = updateCounter(t: percent)
        return start + (update * (end - start));
    }

    //designated init
    
    public init(ringWidth: CGFloat, ringHeight: CGFloat,backgroundColor: UIColor, ringBackgroundColour: UIColor,  ringForegroundColour: UIColor, foreGroundArcWidth: CGFloat, backGroundArcWidth: CGFloat, arcStartAngle: CGFloat, arcEndAngle: CGFloat, arcMargin: CGFloat) {
        
        self.ringBackgroundColour   =   ringBackgroundColour
        self.ringForegroundColour   =   ringForegroundColour
        self.foreGroundArcWidth     =   foreGroundArcWidth
        self.backGroundArcWidth     =   backGroundArcWidth
        self.arcStartAngle          =   arcStartAngle
        self.arcEndAngle            =   arcEndAngle
        self.arcMargin              =   arcMargin
        
        super.init(frame: CGRect(x: 0, y: 0, width: ringWidth, height: ringHeight))
        super.backgroundColor = backgroundColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        
        backgroundArc()
        if showImage {
            drawCenterImage()
        }
        
        if showText {
            drawText(rectSize: CGSize(width: rect.width, height: rect.height))
            self.countFrom(fromValue: 0.0, to: Float(self.animateScale * 100), withDuration: 2.0)
        }
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius: CGFloat = max(bounds.width - arcMargin, bounds.height - arcMargin)
        
        let startAngle: CGFloat = arcStartAngle.degreesToRadians
        let endAngle: CGFloat = arcEndAngle.degreesToRadians
        
        arcPath = UIBezierPath(
            arcCenter: center,
            radius: radius / 2 - backGroundArcWidth / 2, // changed here
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true)
        ringLayer.path = arcPath.cgPath
        
        //make it public on next push
        ringLayer.strokeColor = ringForegroundColour.cgColor
        
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.lineWidth = foreGroundArcWidth
        ringLayer.strokeEnd = 0.0
        layer.addSublayer(ringLayer)
        animateArc(loaderValue: CGFloat(self.animateScale)) // changed here
    }
    
    private func backgroundArc() {
        
        // backGroundArcWidth = 5
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius: CGFloat = max(bounds.width - arcMargin, bounds.height - arcMargin)
        
        let startAngle: CGFloat = arcStartAngle.degreesToRadians
        let endAngle: CGFloat = arcEndAngle.degreesToRadians
        
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius / 2 - backGroundArcWidth / 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true)
        path.lineWidth = backGroundArcWidth
        ringBackgroundColour.setStroke()
        path.stroke()
    }
    
    /**
     Code for animating the color on arc as well as the thumb slider
     
     - parameter loaderValue: the value passed to the animation code. Must be between 0 to 1
     */
    
    private func animateArc(loaderValue: CGFloat) {
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius: CGFloat = max(bounds.width - arcMargin, bounds.height - arcMargin)
        
        let rotationDiff = 360 - abs((arcStartAngle - arcEndAngle))
        let startAngle: CGFloat = arcStartAngle.degreesToRadians
        let endAngle: CGFloat = ((((loaderValue * 100) * abs(rotationDiff)) / 100) + arcStartAngle).degreesToRadians
        
        let thumbPath = UIBezierPath(
            arcCenter: center,
            radius: radius / 2 - backGroundArcWidth / 2, // changed here
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true)
        
        if isthumbImageAvailable && loaderValue != 0 {
            
            thumbImageView.image = thumbImage!
            thumbLayer.contents = thumbImageView.image?.cgImage
            thumbLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            thumbLayer.frame = CGRect(x: 0.0, y: 0.0, width: thumbImageView.image!.size.width, height: thumbImageView.image!.size.height)
            thumbLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: CGFloat(M_PI_2)))
            
            ringLayer.addSublayer(thumbLayer)
            
            let pathAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "position")
            pathAnimation.duration = 2
            pathAnimation.path = thumbPath.cgPath;
            pathAnimation.repeatCount = 0
            pathAnimation.calculationMode = kCAAnimationPaced
            pathAnimation.rotationMode = kCAAnimationRotateAuto
            pathAnimation.fillMode = kCAFillModeForwards
            pathAnimation.isRemovedOnCompletion = false
            thumbLayer.add(pathAnimation, forKey: "movingMeterTip") //need to refactor
        }
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.delegate = self
        animation.duration = 2
        animation.fromValue = 0
        animation.toValue = loaderValue // changed here
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        ringLayer.strokeEnd = loaderValue
        ringLayer.add(animation, forKey: "animateArc")
    }
    
    // drawing center image
    
    func drawCenterImage() {
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius: CGFloat = max(bounds.width - arcMargin, bounds.height - arcMargin)
        
        let imgViewWidth = image!.size.width > radius ? radius : image!.size.width
        let imgViewHeight = image!.size.height > radius ? radius : image!.size.height
        
        let resizedImg = resizeImage(image: image!, targetSize: CGSize(width: imgViewWidth, height: imgViewHeight))
        imgView.frame = CGRect(x: 0, y: 0, width: resizedImg.size.width, height: resizedImg.size.height)
        imgView.center = center
        imgView.image = resizedImg
        imgView.contentMode = .scaleAspectFit
        self.addSubview(imgView)
    }
    
    //to draw the centre text
    
    func drawText(rectSize: CGSize) {
        
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .left
        
        let valueFontAttributes = [NSFontAttributeName: UIFont(name: self.valueFontName, size: self.valueFontSize == -1 ? rectSize.height/5 : self.valueFontSize)!, NSForegroundColorAttributeName: self.fontColor, NSParagraphStyleAttributeName: textStyle] as [String : Any]
        
        let text = NSMutableAttributedString()
        let value = self.animateScale * self.valueMultiplier
        
        if showUnit {
            let unitAttributes = [NSFontAttributeName: UIFont(name: self.unitFontName, size: self.unitFontSize == -1 ? rectSize.height/7 : self.unitFontSize)!, NSForegroundColorAttributeName: self.fontColor, NSParagraphStyleAttributeName: textStyle] as [String : Any]
            let unit = NSAttributedString(string: self.UnitString, attributes: unitAttributes)
            text.append(unit)
        }
        
        let valueSize = ("\(Int(value))" as NSString).size(attributes: valueFontAttributes)
        let unitSize = text.size()
        let centerWidth = valueSize.width
        let centerHeight = valueSize.height
        
        textLabel.frame.size = CGSize(width: valueSize.width, height: valueSize.height)
        textLabel.center = CGPoint(x: (bounds.width/2) - (centerWidth / 2), y: (bounds.height/2) - (centerHeight / 2))
        textLabel.font = UIFont(name: self.valueFontName, size: self.valueFontSize == -1 ? rectSize.height/5 : self.valueFontSize)
        textLabel.textColor = self.fontColor
        self.addSubview(textLabel)
        
        
        // unit string draw rect
        let unitRect = CGRect(x: textLabel.frame.origin.x + textLabel.frame.size.width + 5, y: textLabel.frame.origin.y + (textLabel.frame.size.height - unitSize.height - 3), width: unitSize.width, height: unitSize.height)
        text.draw(in: unitRect)
    }
    
    public func countFrom(fromValue: Float, to toValue: Float, withDuration duration: TimeInterval) {
        
        // Set values
        self.start = fromValue
        self.end = toValue
        self.duration = duration
        self.animationType = UIViewAnimationCurve.easeOut
        self.progress = 0.0
        self.lastUpdate = NSDate.timeIntervalSinceReferenceDate
        
        // Invalidate and nullify timer
        killTimer()
        
        // Handle no animation
        if (duration == 0.0) {
            updateText(value: toValue)
            return
        }
        
        // Create timer
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateValue), userInfo: nil, repeats: true)
    }
    
    func updateText(value: Float) {
        textLabel.text = "\(Int(value))"
    }
    
    func updateValue() {
        
        // Update the progress
        let now = NSDate.timeIntervalSinceReferenceDate
        progress = progress + (now - lastUpdate)
        lastUpdate = now
        
        // End when timer is up
        if (progress >= duration) {
            killTimer()
            progress = duration
        }
        
        updateText(value: currentValue)
        
    }
    
    func killTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func updateCounter(t: Float) -> Float {
        return 1.0 - powf((1.0 - t), kCounterRate)
    }
    
    //to fix the centre image
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    
    
}

extension KXThumbCircularProgressBar: CAAnimationDelegate {
    
    public func animationDidStart(_ anim: CAAnimation) {
        self.delegate?.arcAnimationDidStart?()
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.delegate?.arcAnimationDidStop?()
    }
}
