//
//  Matrix.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/7/29.
//

import Foundation
import GLKit
import Metal

//透视矩阵原理:https://www.cnblogs.com/qhyuan1992/p/6071969.html

extension Matrix4x4 {
    
    /// 生成投影矩阵
    /// - Parameters:
    ///   - fovy: 视角角度
    ///   - aspect: 近平面的宽高比
    ///   - nearZ: 近平面
    ///   - farZ: 远平面
    mutating  func perspective(fovy:Float,aspect:Float,nearZ:Float,farZ:Float) {
        
        ///视景体
        let frustumH = tanf( fovy / 360.0 * Float.pi) * nearZ
        let frustunW = frustumH * aspect
        
        frustum(left: -frustunW, right: frustunW, bottom: -frustumH, top: frustumH, nearZ: nearZ, farZ:farZ)
    }
    
    
    
    mutating func frustum(left:Float,right:Float,bottom:Float,top:Float,nearZ:Float,farZ:Float) {
        let deltaX = right - left
        let deltaY = top - bottom
        let deltaZ = farZ - nearZ
        var frust = Matrix4x4()
        
        if nearZ <= 0.0 ||
            farZ <= 0.0 ||
            deltaX <= 0.0 ||
            deltaY <= 0.0 ||
            deltaZ <= 0.0 {
            return
        }
        
        let values:[Float] =  [
            2.0 * nearZ / deltaX,  0.0,  0.0,    0.0,
            
            0.0, 2.0  * nearZ / deltaY, 0.0, 0.0,
            
            (right + left) / deltaX,  (top + bottom) / deltaY,        -(nearZ + farZ) / deltaZ ,  -1.0,
            
            0.0, 0.0, -2.0 * nearZ * farZ / deltaZ, 0.0
        ]
        
        _ = frust.setValuesWithArray(values)
        
        mutiply(frust)
        
        debugPrint()
    }
    
    
}


