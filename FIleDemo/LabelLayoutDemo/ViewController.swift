//
//  ViewController.swift
//  LabelLayoutDemo
//
//  Created by apple on 2022/2/22.
//

import UIKit

class ViewController: UIViewController {
  
    lazy var lcv:LabelContainerView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let v = LabelContainerView()
        v.backgroundColor = UIColor.lightGray
       
        view.addSubview(v)
            
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            v.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            v.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            v.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor)
        ])
        v.setData(txt0: "临时卡解放路口", txt1: "2313")
        lcv = v
        // Do any additional setup after loading the view.
    }

   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        lcv.setData(txt0: "达拉克的房间联赛", txt1: "65456sa4df5sa4df65sdf6sd4f6是否傲风65456sa4df5sa4df65sdf6sd4f6是否傲风65456sa4df5sa4df65sdf6sd4f6是否傲风")
    }
}

