//
//  ViewController.swift
//  SwiftNewConcurrencyDemo
//
//  Created by apple on 2021/9/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
      
       setupNavigationItem()
       //setupNavigationItem2()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        
    }

}

//MARK: - UINavigationBar
extension UINavigationBar {
   
    
}


//MARK: -
extension ViewController {
    
    func setupNavigationBar() {
        
        guard let navibar = self.navigationController?.navigationBar else {
            return
        }
        
        navibar.isTranslucent = false
        
        if #available(iOS 13.0, *) {
            let stanardAppearance = UINavigationBarAppearance.init(idiom: .phone)
            stanardAppearance.backgroundColor = UIColor.green
            navibar.standardAppearance = stanardAppearance
            if #available(iOS 15.0, *) {
                navibar.scrollEdgeAppearance = stanardAppearance
                navibar.compactScrollEdgeAppearance = stanardAppearance
            }
        }
        else {
            navibar.barTintColor = UIColor.green
        }
    }
    
    private func setupStandaloneNavigationBar() {
        
    }
    
    
    func setupNavigationItem() {
    
        let navigationItem = self.navigationItem
        
        var leftBarButtonItems = [UIBarButtonItem]()
        
//        do {
//            let item = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//            item.width = 50.0
//            leftBarButtonItems.append(item)
//        }
        
        do {
            let btn = UIButton()
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            btn.setTitleColor(.white, for: .normal)
            btn.setTitle("斯图", for: .normal)
            btn.frame = .init(origin: .zero, size: .init(width: 30, height: 30))
            btn.backgroundColor = .blue
            btn.layer.cornerRadius = 4.0
            btn.clipsToBounds = true
            
            let nameBarBtnItem = UIBarButtonItem.init(customView: btn)
            leftBarButtonItems.append(nameBarBtnItem)
        }
       
        
        do {
            
            let line = UIView(frame: .init(x: 0, y: 0, width: 1.0, height: 10.0))
            line.backgroundColor = .red
            
            leftBarButtonItems.append(UIBarButtonItem.init(customView: line))
            
        }
        
        do {
            let imgv = UIImageView()
            imgv.backgroundColor = .darkGray
            imgv.frame = .init(x: 0, y: 0, width: 20, height: 20)
            leftBarButtonItems.append(UIBarButtonItem.init(customView: imgv))
        }
        
        do {
            let state = UILabel()
            state.text = "添加工作状态..."
            state.textColor = .black
            leftBarButtonItems.append(UIBarButtonItem.init(customView: state))
        }
        
        
        navigationItem.leftBarButtonItems = leftBarButtonItems
        
        var rightBarButtomItems = [UIBarButtonItem]()
        
        let rightSystemItems:[UIBarButtonItem.SystemItem] = [
            .add,.done,.bookmarks
        ]
        
        for i in 0..<rightSystemItems.count {
            
            let barButtomItem = UIBarButtonItem.init(barButtonSystemItem: rightSystemItems[i], target: self, action: #selector(pushNewVc(_:)))
            rightBarButtomItems.append(barButtomItem)
        }
        
        navigationItem.rightBarButtonItems = rightBarButtomItems
    }
    
    func setupNavigationItem2() {
        
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 50, height: 150)
        view.backgroundColor = .lightGray
        navigationItem.titleView = view
    }
    
    
    @objc func pushNewVc(_ sender:Any) {
        let vc = ViewController2()
        
       
        navigationController?.pushViewController(vc, animated: true)
    }
}
