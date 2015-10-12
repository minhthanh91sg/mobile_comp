//
//  GridView.swift
//  Tinstagram
//
//  Created by Matheu Malo on 13/10/2015.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

@IBDesignable

class GridView: UIView {

    // MARK: - TO-DO
    // This is a sample. It draws a red line. Please create an Grid.
    
    override func drawRect(rect: CGRect) {
        // Code HERE !!!
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 3.0)
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        
        CGContextMoveToPoint(context, 30, 30)
        CGContextAddLineToPoint(context, 150, 320)
        
        CGContextStrokePath(context)
    }
    

}
