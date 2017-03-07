//
//  ArcGraphicsController.swift
//  GeoLocus
//
//  Created by khan on 20/01/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import Foundation
import UIKit

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
    
    
    @IBInspectable public var foreGroundArcWidth: CGFloat   = 20
    @IBInspectable public var backGroundArcWidth: CGFloat   = 8
    @IBInspectable public var isthumbImageAvailable: Bool = false
    @IBInspectable public var thumbImage: UIImage?
 
    

   @IBInspectable  public var arcMargin: CGFloat                           = 75
    
    
       // must be between [0,1]
    
    public var animateScale: Double = 0.0
    
 
    let ringLayer                                    = CAShapeLayer()
    let thumbLayer                                   = CALayer()
    let imageView                                    = UIImageView()
    var thumbImageView                                   = UIImageView()
    var arcPath                                      = UIBezierPath()
    

	public override func draw(_ rect: CGRect) {

		imageView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(imageView)
		
		backgroundArc()
		//drawCenterImage()
		
		let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
		let radius: CGFloat = max(bounds.width - arcMargin, bounds.height - arcMargin)
		
		let startAngle: CGFloat = 2 * π / 3
		let endAngle: CGFloat = π / 3
		
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

		let startAngle: CGFloat = 2 * π / 3
		let endAngle: CGFloat = π / 3

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

		let startAngle: CGFloat = 2 * π / 3
		let endAngle: CGFloat = CGFloat((loaderValue * 3 * 100) + 120) * CGFloat(M_PI) / 180.0

		let thumbPath = UIBezierPath(
			arcCenter: center,
			radius: radius / 2 - backGroundArcWidth / 2, // changed here
			startAngle: startAngle,
			endAngle: endAngle,
			clockwise: true)

		if isthumbImageAvailable && loaderValue != 0 {

			thumbImageView.image = thumbImage!
			thumbLayer.contents = thumbImageView.image?.cgImage
			thumbLayer.anchorPoint = CGPoint(x: 0.5, y: 0.7)
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
		animation.duration = 2
		animation.fromValue = 0
		animation.toValue = loaderValue // changed here
		animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
		ringLayer.strokeEnd = loaderValue
		ringLayer.add(animation, forKey: "animateArc")
	}

//	func drawCenterImage() {
//
//		if let bgImage = backgroundImage {
//			imageView.image = bgImage
//		}
//		var constraints = [NSLayoutConstraint]()
//
//		constraints.append(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
//
//		constraints.append(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
//
//		constraints.append(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 100))
//
//		constraints.append(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 100))
//		NSLayoutConstraint.activateConstraints(constraints)
//	}
}
