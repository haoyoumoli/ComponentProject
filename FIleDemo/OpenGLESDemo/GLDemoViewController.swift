//
//  GLViewController.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/8/5.
//

import Foundation
import UIKit
import GLKit
import OpenGLES

class GLDemoViewController:  GLKViewController {
    
    lazy private(set) var instancingDemo:InstaningDemo? = InstaningDemo()
    
    let context = EAGLContext.init(api: .openGLES3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.context == nil {
            debugPrint("Failed to create ES context")
            return
        }
        
        EAGLContext.setCurrent(self.context)
        
        let aView:GLKView = self.view as! GLKView
        aView.context = context!
        aView.drawableDepthFormat = .format24
        
    }
    
    func update() {
        instancingDemo?.update(deltaTime: 0.03)
    }
    
    func tearDownGL() {
        instancingDemo = nil
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        instancingDemo?.update(deltaTime: 0.03)
        instancingDemo?.draw(width: view.drawableWidth, height: view.drawableHeight)
    }
}
