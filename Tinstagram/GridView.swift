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
        let gridwidth: CGFloat = 1
        
        var columns : Int
        
        columns = 3
        
        var rows : Int
        
        rows = 3
        
        
        
        let context : CGContextRef = UIGraphicsGetCurrentContext()
        
        CGContextSetLineWidth(context, gridwidth)
        
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
        
        
        
        let columnWidth : CGFloat = self.frame.size.width / (CGFloat(columns))
        
        let rowHeight : CGFloat = self.frame.size.height / (CGFloat(rows) + 1.0)
        
        
        
        
        
        for i in 1...columns-1{
            
            var startPoint: CGPoint = CGPoint(x: columnWidth * CGFloat(i), y: 0.0)
            
            var endPoint : CGPoint = CGPoint(x:startPoint.x, y:self.frame.size.height)
            
            
            
            CGContextMoveToPoint(context, startPoint.x, startPoint.y)
            
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y)
            
            CGContextStrokePath(context)
            
            
            
        }
        
        
        
        for j in 1...rows {
            
            var startPoint : CGPoint = CGPoint(x: 0.0, y: rowHeight * CGFloat(j))
            
            var endPoint : CGPoint = CGPoint(x: self.frame.size.width, y: startPoint.y)
            
            
            
            CGContextMoveToPoint(context, startPoint.x, startPoint.y)
            
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y)
            
            CGContextStrokePath(context)
            
        }
        
        
        
        
        
    }
    
}

