//
//  ViewController2.swift
//  SwiftNewConcurrencyDemo
//
//  Created by apple on 2021/9/24.
//

import UIKit




class ViewController2:UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈"
        view.backgroundColor = UIColor.init(red: CGFloat( arc4random() % 255) / 255.0 , green:  CGFloat(arc4random() % 255) / 255.0 , blue:  CGFloat(arc4random() % 255) / 255.0 , alpha: 1.0)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    private func setupNavigationBar() {
        guard let navibar = self.navigationController?.navigationBar else {
            return
        }
        
        if #available(iOS 13.0, *) {
            let stanardAppearance = UINavigationBarAppearance.init(idiom: .phone)
            stanardAppearance.backgroundColor = UIColor.red
            navibar.standardAppearance = stanardAppearance
            if #available(iOS 15.0, *) {
                navibar.scrollEdgeAppearance = stanardAppearance
                navibar.compactScrollEdgeAppearance = stanardAppearance
            }
        }
        else {
            navibar.barTintColor = UIColor.red
        }
    }
    
   
}
