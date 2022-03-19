//
//  ViewController.swift
//  ButtonDemo
//
//  Created by apple on 2021/8/2.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let button = UIButton.init(frame: .zero)
        button.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
        button.setTitle("按钮", for: .normal)
        button.setTitle("😿", for: .highlighted)
        button.setTitleColor(UIColor.white, for: [.normal,.highlighted ])
   
        button.setBackgroundImage(UIImage.image(with: UIColor.blue), for: .normal)
        button.setBackgroundImage(UIImage.image(with: UIColor.blue.withAlphaComponent(0.5)), for: .highlighted)
        
        view.addSubview(button)
        
        
        let customBtn = CustomButton.init(frame: .init(x: 50, y: 110, width: 200, height: 50))
        customBtn.setBackgroundImage(UIImage.image(with: UIColor.gray), for: .highlighted)
        customBtn.setBackgroundImage(UIImage.image(with: UIColor.gray.withAlphaComponent(0.2)), for: .highlighted)
        view.addSubview(customBtn)
        
        
    }


}

