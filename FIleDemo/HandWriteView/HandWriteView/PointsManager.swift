//
//  PathManager.swift
//  HandWriteView
//
//  Created by apple on 2021/5/27.
//

import Foundation
import UIKit

/// 轨迹管理器
class PointsManager {
    
    private(set) var points:[[CGPoint]]
    
    init(points:[[CGPoint]]) {
        self.points = points
    }
}

//MARK: 添加轨迹点
extension PointsManager {
    func addPath(with startPoint:CGPoint) {
        self.points.append([startPoint])
    }
    
    var lastedPath:[CGPoint]?  {
        return points.last
    }
    
    func lastedPathAppend(point:CGPoint) {
        if var last = points.last {
            last.append(point)
            points[points.count - 1] = last
        }
    }
}

//MARK: 清空
extension PointsManager{
    func clear() {
        points.removeAll()
    }
}


//MARK: 轨迹frame
extension PointsManager {
    
    var trajectoryFrame:CGRect {
        if points.count == 0 {
            return .zero
        }
        
        var minX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxX = CGFloat.zero
        var maxY = CGFloat.zero
        
        for i in 0..<points.count {
            let ap = points[i]
            for j in 0..<ap.count {
                let point = ap[j]
                if point.x < minX {
                    minX = point.x
                } else if point.x > maxX {
                    maxX = point.x
                }
                
                if point.y < minY {
                    minY = point.y
                } else if point.y > maxY {
                    maxY = point.y
                }
            }
        }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}
