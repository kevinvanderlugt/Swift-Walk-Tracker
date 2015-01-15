//
//  AnimatedStartButton.swift
//  walktracker
//
//  Created by Kevin VanderLugt on 1/13/15.
//  Copyright (c) 2015 Alpine Pipeline. All rights reserved.
//

import CoreGraphics
import QuartzCore
import UIKit

class AnimatedStartButton : UIButton {

    // The horizontal disantce between the two lines in pause mode
    let pauseSpace: CGFloat = 10.0
    
    // This is due to the graphic being larger from the drop shadows
    let shadowPadding: CGFloat = 8.0
    
    let linePath: CGPath = {
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddLineToPoint(path, nil, 0, 12)
        
        return path
    }()
    
    let bottomTransform = CATransform3DRotate(CATransform3DMakeTranslation(0, 2, 0), CGFloat(M_PI/4), 0, 0, 1)
    let topTransform = CATransform3DRotate(CATransform3DMakeTranslation(-10, -2, 0), CGFloat(-M_PI/4), 0, 0, 1)
    
    override var selected: Bool {
        didSet {
            addTransforms()
        }
    }
    
    var top: CAShapeLayer! = CAShapeLayer()
    var bottom: CAShapeLayer! = CAShapeLayer()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupPaths()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupPaths()
    }
    
    func setupPaths() {
        let lineWidth: CGFloat = 2
        
        self.top.path = linePath
        self.bottom.path = linePath
        
        for layer in [ self.top, self.bottom ] {
            layer.fillColor = nil
            layer.strokeColor = UIColor.whiteColor().CGColor
            layer.lineWidth = lineWidth
            layer.lineCap = kCALineCapSquare
            layer.masksToBounds = true
            
            let strokingPath = CGPathCreateCopyByStrokingPath(layer.path, nil, lineWidth*2, kCGLineCapSquare, kCGLineJoinMiter, 0)
            layer.bounds = CGPathGetPathBoundingBox(strokingPath)
            layer.actions = [
                "strokeStart": NSNull(),
                "strokeEnd": NSNull(),
                "transform": NSNull()
            ]
            
            self.layer.addSublayer(layer)
        }
        
        self.top.anchorPoint = CGPointMake(0.5, 0.0)
        self.top.position = CGPointMake(self.frame.size.width/2 + pauseSpace/2, (self.frame.size.height-shadowPadding)/2 - 12/2 )
        self.top.transform = topTransform
        
        self.bottom.anchorPoint = CGPointMake(0.5, 1.0)
        self.bottom.position = CGPointMake(self.frame.size.width/2 - pauseSpace/2, self.top.position.y + 12 +  shadowPadding/2)
        self.bottom.transform = bottomTransform
    }

    
    func addTransforms() {
        let bottomAnimation = CABasicAnimation(keyPath: "transform")
        bottomAnimation.duration = 0.4
        bottomAnimation.fillMode = kCAFillModeBackwards
        bottomAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, -0.8, 0.5, 1.85)
        
        let topAnimation = bottomAnimation.copy() as CABasicAnimation
        
        if (selected) {
            bottomAnimation.toValue = NSValue(CATransform3D: CATransform3DIdentity)
            topAnimation.toValue  = NSValue(CATransform3D: CATransform3DIdentity)
        }
        else {
            bottomAnimation.toValue = NSValue(CATransform3D: bottomTransform)
            topAnimation.toValue = NSValue(CATransform3D: topTransform)
        }
        self.bottom.kv_applyAnimation(bottomAnimation)
        self.top.kv_applyAnimation(topAnimation)
    }
    
}

extension CALayer {
    func kv_applyAnimation(animation: CABasicAnimation) {
        let copy = animation.copy() as CABasicAnimation
        
        if copy.fromValue == nil {
            copy.fromValue = self.presentationLayer().valueForKeyPath(copy.keyPath)
        }
        
        self.addAnimation(copy, forKey: copy.keyPath)
        self.setValue(copy.toValue, forKeyPath:copy.keyPath)
    }
}
