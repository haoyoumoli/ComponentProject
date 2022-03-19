//
//  UITableView+Hook.swift
//  TableViewTouchStatisticsDemo
//
//  Created by apple on 2021/10/29.
//

import UIKit

extension UITableView {
   open class func installTouchesMethodHook() -> Bool {
       
      return RuntimeUtil.hookMethod(for: self, originalSel: #selector(touchesBegan(_:with:)), swizzledSel: #selector(hook_touchesBegan(_:with:)))
     
   }
    
    
   @objc open func hook_touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        debugPrint("hook_touchesBegan :\(self)")
       hook_touchesBegan(touches, with: event)
    }
}
