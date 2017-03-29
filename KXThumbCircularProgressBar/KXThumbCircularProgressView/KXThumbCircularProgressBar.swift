//
//  ArcGraphicsController.swift
//  GeoLocus
//
//  Created by khan on 20/01/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol KXArcNotifyDelegate {
    
    @objc optional func arcAnimationDidStart()
    @objc optional func arcAnimationDidStop()
}

/// This file creates a resuable component Arc view.

let π: CGFloat = CGFloat(M_PI)

@IBDesignable public class KXThumbCircularProgressBar: UIView {
    
    @IBInspectable public var ringBackgroundColour: UIColor = UIColor(netHex: 0xaba8a8)
    @IBInspectable public var ringForegroundColour: UIColor = UIColor.green
    
    
    //	@IBInspectable public var backgroundImage: UIImage?
    
    //commented for next release feature
    //   @IBInspectable var lowLevelColor: UIColor        = UIColor.red
    //   @IBInspectable var midLevelColor: UIColor        = UIColor.orange
    //   @IBInspectable var highLevelColor: UIColor       = UIColor.green
    
    // must be between [0,100]
    @IBInspectable public var animateScale: Double = 0.0
    
    @IBInspectable public var foreGroundArcWidth: CGFloat   = 20
    @IBInspectable public var backGroundArcWidth: CGFloat   = 8
    @IBInspectable public var isthumbImageAvailable: Bool = false
    @IBInspectable public var thumbImage: UIImage?
    @IBInspectable public var arcStartAngle: CGFloat = 120
    @IBInspectable public var arcEndAngle: CGFloat = 60
    
    @IBInspectable public var arcMargin: CGFloat = 75
    
    // Display Image or Text
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
    
    let ringLayer = CAShapeLayer()
    let thumbLayer = CALayer()
    let imgView = UIImageView()
    var thumbImageView = UIImageView()
    var arcPath = UIBezierPath()
    
    // Arc animation notify Delegate
    public var delegate: KXArcNotifyDelegate?
    
    public override func draw(_ rect: CGRect) {
        
        backgroundArc()
        if showImage {
            drawCenterImage()
        }
        
        if showText {
            drawText(rectSize: CGSize(width: rect.width, height: rect.height))
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
        
        let textLabel = UILabel()
        textLabel.frame.size = CGSize(width: valueSize.width, height: valueSize.height)
        textLabel.center = CGPoint(x: (bounds.width/2) - (centerWidth / 2), y: (bounds.height/2) - (centerHeight / 2))
        textLabel.font = UIFont(name: self.valueFontName, size: self.valueFontSize == -1 ? rectSize.height/5 : self.valueFontSize)
        textLabel.text = "\(Int(value)) "
        textLabel.textColor = self.fontColor
        self.addSubview(textLabel)
        
        let duration: Double = 2.0 //seconds
        DispatchQueue.global().async {
            for i in 0 ..< (Int(value) + 1) {
                let sleepTime = UInt32(duration/Double(value) * 280000.0)
                usleep(sleepTime)
                DispatchQueue.main.async {
                    textLabel.text = "\(i)"
                }
            }
        }
        
        // unit string draw rect
        let unitRect = CGRect(x: textLabel.frame.origin.x + textLabel.frame.size.width + 5, y: textLabel.frame.origin.y + (textLabel.frame.size.height - unitSize.height - 3), width: unitSize.width, height: unitSize.height)
        text.draw(in: unitRect)
    }
    
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
