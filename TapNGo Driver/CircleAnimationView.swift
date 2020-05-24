//
//  CircleAnimationView.swift
//  TapNGo Driver
//
//  Created by Admin on 10/04/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import UIKit

class CircleAnimationView:UIView
{
    let circle = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)        

    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setup()
    }
    func setup()
    {
        self.backgroundColor = .white
        
        let outCircle = CAShapeLayer()
        outCircle.path = UIBezierPath(ovalIn: self.bounds).cgPath
        outCircle.fillColor = UIColor.clear.cgColor
        outCircle.strokeColor = UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1).cgColor
        outCircle.lineWidth = 4
        outCircle.strokeStart = 0
        outCircle.strokeEnd = 1.0
        self.layer.addSublayer(outCircle)

        circle.path = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: self.bounds.width / 2.0, startAngle: CGFloat(Float.pi / -2.0), endAngle: CGFloat((Float.pi*2)-(Float.pi/2)), clockwise: true).cgPath
        circle.fillColor = UIColor.clear.cgColor
        circle.strokeColor = UIColor.red.cgColor
        circle.lineWidth = 4
        circle.strokeStart = 0
        circle.strokeEnd = 0
        self.layer.addSublayer(circle)
    }
    func animateCircle(_ duration:CFTimeInterval, startFrom:Int)
    {
        print(duration)//60
        print(startFrom)
        circle.strokeEnd = 1.0
        let drawAnimation = CABasicAnimation(keyPath: "strokeEnd")
        drawAnimation.duration = duration - Double(startFrom)
        drawAnimation.fromValue = Double(startFrom)/duration
        drawAnimation.toValue   = 1.0
        drawAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        circle.add(drawAnimation, forKey: "drawCircleAnimation")
    }
}
