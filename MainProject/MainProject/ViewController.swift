//
//  ViewController.swift
//  MainProject
//
//  Created by apple on 2022/2/10.
//

import UIKit
import HomeComponent
import SnapKit
import ProtocolServiceKit
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let homeViewController = HomeComponent.ViewController()
            self.present(homeViewController, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }


}

