//
//  HandWriteView.swift
//  HandWriteView
//
//  Created by apple on 2021/5/27.
//

import Foundation
import UIKit

///手写展示view
class HandWriteView: UIView {
    let pointsManager = PointsManager(points: [])
    
    var lineWidth:CGFloat = 3.0
    var lineColor = UIColor.black
}

//MARK: 绘制
extension HandWriteView {
    override func draw(_ rect: CGRect) {
        if let ctx = UIGraphicsGetCurrentContext() {
            
            for i in 0..<pointsManager.points.count {
                ///一条轨迹
                let aTrajectory = pointsManager.points[i]
                for j in 0..<aTrajectory.count {
                    if j == 0 {
                        ctx.move(to: aTrajectory[j])
                    } else {
                        ctx.addLine(to: aTrajectory[j])
                    }
                }
            }
            
            lineColor.set()
            ///设置线条拐弯
            ctx.setLineJoin(.bevel)
            //设置连接线的样式
            ctx.setLineCap(.round)
            ctx.setLineWidth(lineWidth)
            ctx.strokePath()
        }
    }
}

//MARK: 处理手势事件
extension HandWriteView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        pointsManager.addPath(with: point)
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.previousLocation(in: self)
        pointsManager.lastedPathAppend(point: point)
        setNeedsDisplay()
    }

}


//MARK: 轨迹的图片
extension HandWriteView {
    var scrawlImage:UIImage? {
        UIGraphicsBeginImageContext(self.bounds.size)
        
        defer { UIGraphicsEndImageContext() }
        
        let trajectoryFrame = pointsManager.trajectoryFrame
        guard
            trajectoryFrame != .zero,
            let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        ctx.setFillColor(UIColor.clear.cgColor)
        self.layer.render(in: ctx)
        
        guard let fullImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        
        guard let scrawlImage =
                fullImage.cgImage?.cropping(to: trajectoryFrame) else {
            return nil
        }
        
        return UIImage(cgImage: scrawlImage)
    }
}

//MARK: 清空绘制的内容
extension HandWriteView {
    func clear() {
        pointsManager.clear()
        setNeedsDisplay()
    }
}
