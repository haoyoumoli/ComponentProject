//
//  ViewController.swift
//  WWDCDemos
//
//  Created by apple on 2022/2/17.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var geo = GeometricVector.init(SIMD2.init(1.0, 2.0))
    
        let x = geo.x
        let y = geo.y
        geo.x = x
        geo.y = y
       
        
        let wwraper = WWraper.init(
            a: .init(a1: 10, a2: 11),
            b: .init(b1: 12, b2: "13")
        )
        
        debugPrint(wwraper.a1,wwraper.a2,wwraper.b1,wwraper.b2)
        
        let testType = TestType()
        
        debugPrint(testType)
        debugPrint(testType.path)
        // Do any additional setup after loading the view.
    }


}

