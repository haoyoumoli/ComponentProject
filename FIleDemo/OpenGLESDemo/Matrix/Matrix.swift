//
//  ESMatrix.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/7/29.
//

import Foundation


//MARK: - 一般矩阵

struct Matrix:MatrixProtocol {
    let rows:Int
    let cols:Int
    
    fileprivate(set) var m:ContiguousArray<Float>
    
    init(_ rows:Int , _ cows:Int) {
        self.rows = rows
        self.cols = rows
        self.m = .init(repeating: 0.0, count: self.rows * self.cols)
    }
}

extension Matrix {
    subscript(at row:Int,_ col:Int) -> Float {
        get {
            return m[row * cols + col]
        }
        
        set {
            m[row * cols + col] = newValue
        }
    }
}


