//
//  ViewController.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/7/20.
//

import UIKit
import GLKit
import Darwin


fileprivate func printCost(_ label:String,_ opearation:() -> Void) {
    let start = Date().timeIntervalSince1970
    opearation()
    debugPrint("\(label) cost:\(Date().timeIntervalSince1970 - start)")
}

class ViewController: UIViewController {
    
    let glkView = GLKView(frame: .zero)
    
    private(set) var currentDemo:DemoProtocol? = nil
    
    private(set) var link:CADisplayLink? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGLKView()
        startDisplayLink()
        installDemo()
 
    }
    
   
    
    func startDisplayLink() {
        
        link = CADisplayLink.init(target: self, selector: #selector(linkUpdate))
        link?.add(to: .main, forMode: .default)
    }
    
    func setupGLKView() {
        
        if EAGLContext.current() == nil {
            let ctx = EAGLContext.init(api: EAGLRenderingAPI.openGLES3)
            EAGLContext.setCurrent(ctx)
        }
        
        glkView.context = EAGLContext.current()!
        glkView.drawableDepthFormat = .format24
        glkView.delegate = self
        view.addSubview(glkView)
        
        
        glkView.translatesAutoresizingMaskIntoConstraints = false
        glkView.leftAnchor
            .constraint(equalTo: view.leftAnchor).isActive = true
        glkView.rightAnchor
            .constraint(equalTo: view.rightAnchor).isActive = true
        glkView.topAnchor
            .constraint(equalTo: view.topAnchor).isActive = true
        glkView.bottomAnchor
            .constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    func appleSysctlDemo() {
        var query = [CTL_HW,HW_CACHELINE]
        var result:CInt = 0
        var resultSize = MemoryLayout<CInt>.size
        let r = sysctl(&query, CUnsignedInt(query.count), &result, &resultSize, nil, 0)
        precondition(r == 0,"Cannot query cache line size")
        precondition(query.count == MemoryLayout<CInt>.size) //??? apple 为啥这样写?这是不对的呀
    }
    
    
    @objc func linkUpdate() {
        if self.currentDemo?.isSupportUpdate() == true {
            self.currentDemo?.update()
            self.glkView.setNeedsDisplay()
        }
    }
    
}

//MARK: - 切换demo
extension ViewController: GLKViewDelegate {
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        self.currentDemo?
            .draw(width: view.drawableWidth, height: view.drawableHeight)
    }
    
}

//MARK: -
extension ViewController {
    func installDemo() {
        
        //currentDemo = HelloTrigangle()
        
        //currentDemo = VAOAndIndicesTrigangle()
        
        ///这个Demo会占用非常多的CPU
       // currentDemo = InstaningDemo()
        
        // currentDemo = C8SimpleVertexShaderDemo()
        
       // currentDemo = MipMap2DDemo()
        
       // currentDemo = SimpleTexture2D()
        
       // currentDemo = SimpletTextureCubemap()
      
      //  currentDemo = TextureWrapDemo()
        
        ///c10
         //currentDemo = MutilTextureDemo()
        
        ///c11
          currentDemo = MRTDemo()
    }
}
