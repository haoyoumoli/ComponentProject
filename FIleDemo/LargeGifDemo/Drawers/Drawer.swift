//
//  Drawer.swift
//  GestureTransformDemo
//
//  Created by apple on 2022/6/21.
//

import Foundation
import CoreGraphics
import UIKit

///具有绘制能力接口
protocol Drawable {
    func draw(on context:CGContext,frame:CGRect)
}



class RectDrawer:Drawable {
    
    var lineWidth:CGFloat
    var strokeColor:UIColor
    var fillColor:UIColor
    
    init(lineWidth:CGFloat,strokeColor:UIColor,fillColor:UIColor) {
        self.lineWidth = lineWidth
        self.strokeColor = strokeColor
        self.fillColor = fillColor
    }
    
    func draw(on context: CGContext, frame: CGRect) {
        context.saveGState()
        defer {  context.restoreGState() }
        
        //stroke
        context.addRect(frame)
        context.setLineWidth(lineWidth)
        context.setStrokeColor(strokeColor.cgColor)
        context.strokePath()
        
        //fill
        let inset = lineWidth * 0.5
        context.addRect(frame.inset(by: .init(top: inset, left: inset, bottom: inset, right: inset)))
        context.setFillColor(fillColor.cgColor)
        context.fillPath()
       
    }
    
    
}

class TwoRectView:UIView {
    
    var redRectDrawer = RectDrawer(lineWidth: 2.0, strokeColor: UIColor.red, fillColor: UIColor.clear)
    
    var greenRectDrawer = RectDrawer(lineWidth: 4.0, strokeColor: UIColor.blue, fillColor: UIColor.green)
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        redRectDrawer.draw(on: ctx, frame: .init(x: 0, y: 0, width: bounds.width * 0.5, height: bounds.height * 0.5))
        
        greenRectDrawer.draw(on: ctx,frame: .init(x: 0, y: 0.5 * bounds.height, width: bounds.width * 0.5, height: bounds.height))
    }
}



