//
//  ViewController.swift
//  HomeProject
//
//  Created by apple on 2022/2/10.
//

import UIKit
import SnapKit

public class ViewController: UIViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let blueView = UIView()
        blueView.backgroundColor = UIColor.blue
        view.addSubview(blueView)
        blueView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(100)
        }
        // Do any additional setup after loading the view.
        
        debugPrint("HomeProject aaa")
    }


}

