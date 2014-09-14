//
//  MyKnobControl.swift
//  KnobControlDemo-Swift
//
//  Created by 陈静 on 14-9-14.
//  Copyright (c) 2014年 Your Organization. All rights reserved.
//

import Foundation

import UIKit

public func getKnobControl(viewPort: UIView, radius: Int) -> IOSKnobControl{
    
    // getScreen size
    let screenBounds :CGRect = UIScreen.mainScreen().bounds
    
    let screenWidth = screenBounds.width
//    println(screenWidth)
    let originalFrame = viewPort.frame
    
    // if radius is very large then have to start out size (to the left of ) the screen
    let startingX = (Double(screenWidth) - Double(radius)) / 2.0
//    println(startingX)
    
    // full frame for the partially hidden knob control
    let fullFrame = CGRect(x : startingX, y : Double(originalFrame.origin.y), width : Double(radius), height : Double(radius))
    
    // wide frame ( not high, but original height ) frame for the view port of the knob control
    let wideFrame = CGRect(x: fullFrame.origin.x, y: fullFrame.origin.y, width: fullFrame.width, height:originalFrame.height)
//    println(originalFrame.origin.y)
    
    // update the view port frame so it also extends according to the radius
    // otherwise it may cause error with position centering
    viewPort.frame = wideFrame
    
    viewPort.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
    
    // Create the knob control
    let knobControl = IOSKnobControl(frame: fullFrame)
    knobControl.circular = false
    // leave a bit room for the image, may or may not be necessary, depends
//    knobControl.transform = CGAffineTransformMakeTranslation(CGFloat(0.0), CGFloat(20.0))
    
    knobControl.setFillColor(UIColor.clearColor(), forState: .Normal)
    knobControl.setFillColor(UIColor.clearColor(), forState: .Highlighted)
    
    // time for auto animation when the knob snaps back to allowed slots. 0.5 is not slow yet visible.  
    knobControl.timeScale = 0.5
    // Set the .mode property of the knob control
    knobControl.mode = .LinearReturn
    // Configure the gesture to use
    knobControl.gesture = .OneFingerRotation
    // clockwise or counterclockwise
    knobControl.clockwise = false

    // specify an action for the .ValueChanged event and add as a subview to the knobHolder UIView
    viewPort.addSubview(knobControl)
    
    return knobControl
    
}