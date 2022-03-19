//
//  ViewController.swift
//  EmitterDemo
//
//  Created by apple on 2021/5/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let emitterLayer = CAEmitterLayer()
        
        emitterLayer.emitterPosition = CGPoint(x: 0.5 * view.bounds.width, y: 100)
        emitterLayer.emitterShape = .cuboid
        
        let cell = CAEmitterCell()
        cell.birthRate = 30
        cell.lifetime = 100
        cell.velocity = 100
       // cell.scale = 0.1
        
    
        cell.emissionRange = CGFloat.pi
        cell.contents = UIImage(named: "red_flower")!.cgImage
        
        emitterLayer.emitterCells = [cell]
        view.layer.addSublayer(emitterLayer)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let iphoneScreens = IphoneScreens()
       // try? iphoneScreens.writeJson(to: URL(fileURLWithPath: "/Users/apple/Desktop/iphone-screen.json"))
        debugPrint(iphoneScreens.screenInfos.map{ ($0.0,$0.1.ratio)})
        debugPrint(iphoneScreens.ratioSet)
    }
}



