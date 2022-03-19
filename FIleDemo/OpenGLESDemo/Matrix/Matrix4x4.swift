//
//  Matrix4x4.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/8/5.
//

import Foundation

//MARK: - 4x4 矩阵
struct Matrix4x4 {
    private var mat:Matrix
    
    fileprivate init(_ mat:Matrix) {
        self.mat = mat
    }
    
    init() {
        self.init(Matrix(4,4))
    }
    
    static var stride:Int {
        return MemoryLayout<Float>.stride * 16
    }
}

// 实现 MatrixProtocol 协议
extension Matrix4x4:MatrixProtocol {
    var rows: Int {
        return mat.rows
    }
    
    var cols: Int {
        return mat.cols
    }
    
    subscript(at row: Int, col: Int) -> Float {
        get {
            mat[at: row, col]
        }
        set {
            mat[at: row, col] = newValue
        }
    }
}

//MARK: - 变换为单元矩阵
extension MatrixProtocol where Self == Matrix4x4 {
    mutating func becomeIdentity() {
        for i in 0..<rows {
            for j in 0..<cols {
                self[at: i, j] = (i == j ? 1 : 0)
            }
        }
    }
}



//MARK: - 矩阵操作
extension Matrix4x4 {
    mutating func mutiply(_ m: Matrix4x4 ) {
        let temp = self
        var i = 0
        while i < rows {
            self[at: i, 0] = (temp[at: i, 0] * m[at: 0, 0]) +
                             (temp[at: i, 1] * m[at: 1, 0]) +
                             (temp[at: i, 2] * m[at: 2, 0]) +
                             (temp[at: i, 3] * m[at: 3, 0])
            
            self[at: i, 1] = (temp[at: i, 0] * m[at: 0, 1]) +
                             (temp[at: i, 1] * m[at: 1, 1]) +
                             (temp[at: i, 2] * m[at: 2, 1]) +
                             (temp[at: i, 3] * m[at: 3, 1])
            
            self[at: i, 2] = (temp[at: i, 0] * m[at: 0, 2]) +
                             (temp[at: i, 1] * m[at: 1, 2]) +
                             (temp[at: i, 2] * m[at: 2, 2]) +
                             (temp[at: i, 3] * m[at: 3, 2])
            
            self[at: i, 3] = (temp[at: i, 0] * m[at: 0, 3]) +
                             (temp[at: i, 1] * m[at: 1, 3]) +
                             (temp[at: i, 2] * m[at: 2, 3]) +
                             (temp[at: i, 3] * m[at: 3, 3])
            
            i += 1
        }
    }
    
    mutating func
    translate(tx:Float,ty:Float,tz:Float) {
        self[at: 3, 0] += (self[at: 0, 0] * tx + self[at: 1, 0] * ty + self[at: 2, 0] * tz)
        self[at: 3, 1] += (self[at: 0, 1] * tx + self[at: 1, 1] * ty + self[at: 2, 1] * tz)
        self[at: 3, 2] += (self[at: 0, 2] * tx + self[at: 1, 2] * ty + self[at: 2, 2] * tz)
        self[at: 3, 3] += (self[at: 0, 3] * tx + self[at: 1, 3] * ty + self[at: 2, 3] * tz)
    }
    
    mutating func
    rotate(angle:Float,x:Float,y:Float,z:Float) {
        var x = x ,y = y,z = z
        
        let sinAngle = sinf(angle * Float.pi / 180.0)
        let cosAngle = cosf(angle * Float.pi / 180.0)
        let mag = sqrtf(x * x + y * y + z * z)
        
        if (mag > 0.0) {
            
            x /= mag
            y /= mag
            z /= mag
            
            let xx = x * x
            let yy = y * y
            let zz = z * z
            let xy = x * y
            let yz = y * z
            let zx = z * x
            let xs = x * sinAngle
            let ys = y * sinAngle
            let zs = z * sinAngle
            let oneMinusCos = 1.0 - cosAngle
            
            var rotMat = Matrix4x4()
            _ = rotMat.setValuesWithArray([
                ( oneMinusCos * xx ) + cosAngle, ( oneMinusCos * xy ) - zs, ( oneMinusCos * zx ) + ys,  0.0,
                ( oneMinusCos * xy ) + zs,       ( oneMinusCos * yy ) + cosAngle, ( oneMinusCos * yz ) - xs, 0.0,
                ( oneMinusCos * zx ) - ys,       ( oneMinusCos * yz ) + xs, ( oneMinusCos * zz ) + cosAngle,   0.0,
                0.0,                             0.0,                    0.0,                                   1.0
            ])
            
            rotMat.mutiply(self)
            _ = setValuesWithArray(rotMat.getValues())
        }
    }
}
