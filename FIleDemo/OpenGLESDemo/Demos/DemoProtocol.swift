//
//  DemoProtocol.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/8/5.
//

import Foundation

protocol DemoProtocol {
    
    init?()
    
    func isSupportUpdate() -> Bool
    func update()
    
    func draw(width:Int,height:Int)
    
    func shutDown()
}


extension DemoProtocol {
    
    func isSupportUpdate() -> Bool {
        return false
        
    }
    
    func update() { }
}

