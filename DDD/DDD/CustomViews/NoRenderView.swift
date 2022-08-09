//
//  NoRenderView.swift
//  DDD
//
//  Created by apple on 2022/7/20.
//

import UIKit

class NoRenderView: UIView {
    
    override func draw(_ rect: CGRect) {
        //does nothing
    }
    
    override class var layerClass: AnyClass {
        return NoRenderLayer.self
    }
}

class NoRenderLayer:CALayer {
    override func draw(in ctx: CGContext) {
        //does nothing
    }
}
