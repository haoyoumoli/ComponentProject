//
//  MyNavigationController.swift
//  SwiftNewConcurrencyDemo
//
//  Created by apple on 2021/9/24.
//

import UIKit

class MyNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        //解决在设置了navigationbar left item 只收侧滑返回失效的bug
//        if self.responds(to: #selector(getter: interactivePopGestureRecognizer)) {
//            self.interactivePopGestureRecognizer?.isEnabled = true
//            self.interactivePopGestureRecognizer?.delegate = self
//        }
    }
    
}

extension MyNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.interactivePopGestureRecognizer {
            if self.viewControllers.count == 1 {
                return false
            }
        }
        return true
    }
    
}
