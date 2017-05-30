//
//  Head_Image.swift
//  App
//
//  Created by Kyle Tan on 5/18/17.
//  Copyright © 2017 Kyle Tan. All rights reserved.
//

import Foundation
import UIKit

class Head_Image : UIImageView
{
    var timer = Timer()
    var curImageIndex = 0
    var curRepIndex = 0
    var isTimerRunning = false
    var shapeLayer = CAShapeLayer()
    var shapeLayer2 = CAShapeLayer()
    
    func animate(repetitions: Int)
    {
        //transform code
        self.transform = CGAffineTransform(scaleX: 1, y: 0)
        UIView.animate(withDuration: 0.5, animations: {
            self.transform = CGAffineTransform.identity
            
        }){ (finished) in
            self.timer = Timer.scheduledTimer(timeInterval: 0.04, target: self, selector: (#selector(Head_Image.next_image)), userInfo: nil, repeats: true)
        }
        
        //transform code end

        curRepIndex = repetitions
        isTimerRunning = true
        animate_border()
    }
    
    
    
    func next_image()
    {
        if(curRepIndex <= 0 && curImageIndex == 0)
        {
            timer.invalidate()
            isTimerRunning = false
            return
        }
        if(curImageIndex == 94)
        {
            curImageIndex = 0
            curRepIndex -= 1
        }
        else
        {
           curImageIndex += 1
        }
        
        let new_image_text = "talkingnormal\(curImageIndex)"
        self.image = UIImage(named: new_image_text)
    }
    
    func animate_border()
    {
        //Up, Right border
        
        // create whatever path you want
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 100, y: 0))
        path.addLine(to: CGPoint(x: 100, y: 113))
        
        // create shape layer for that path
        shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer.strokeColor = #colorLiteral(red: 0.9784535766, green: 0.6787097454, blue: 0.7884691358, alpha: 1).cgColor
        shapeLayer.lineWidth = 6
        shapeLayer.path = path.cgPath
        
        layer.addSublayer(shapeLayer)
        // animate it
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 0.7
        shapeLayer.add(animation, forKey: "MyAnimation")
        
        //Down, Left border
        
        // create whatever path you want
        let path2 = UIBezierPath()
        path2.move(to: CGPoint(x: 100, y: 110))
        path2.addLine(to: CGPoint(x: 0, y: 110))
        path2.addLine(to: CGPoint(x: 0, y: -3))
        
        // create shape layer for that path
        shapeLayer2 = CAShapeLayer()
        shapeLayer2.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer2.strokeColor = #colorLiteral(red: 0.9784535766, green: 0.6787097454, blue: 0.7884691358, alpha: 1).cgColor
        shapeLayer2.lineWidth = 6
        shapeLayer2.path = path2.cgPath
        
        layer.addSublayer(shapeLayer2)
        // animate it
        let animation2 = CABasicAnimation(keyPath: "strokeEnd")
        animation2.fromValue = 0
        animation2.duration = 0.5
        shapeLayer2.add(animation2, forKey: "MyAnimation")
    }
    
    func unanimate()
    {
        //transform code
        UIView.animate(withDuration: 0.5, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 0.0001)
            
        }){ (finished) in
            self.shapeLayer.removeFromSuperlayer()
            self.shapeLayer2.removeFromSuperlayer()
        }
    
    }
    
    
    
    
    
}
