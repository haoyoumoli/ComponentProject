//
//  ControlTarget.swift
//  AttributeTextDemo
//
//  Created by apple on 2021/11/16.
//

import Foundation
import UIKit

fileprivate final class ControlTarget {
    
    let action:UIControl.Action
    
    init(action:@escaping UIControl.Action) {
        self.action = action
    }
    
    deinit {
        debugPrint("ControlTarget \(self) deinit")
    }
    
    var actionSel:Selector {
        return #selector(targetAction(sender:event:))
    }
    
    @objc func targetAction(sender:UIControl,event:UIEvent) {
        action(sender,event)
    }
}

//MARK: - 
extension UIControl {
    fileprivate static var key: () = ()
    
    typealias Action = (_ sender:UIControl,_ event:UIEvent) -> Void
    
    fileprivate var controlTargets:[ControlTarget] {
        get {
            var arr = objc_getAssociatedObject(self, &UIControl.key) as? [ControlTarget]
            if arr == nil {
                arr = [ControlTarget]()
                objc_setAssociatedObject(self, &UIControl.key, arr, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return arr!
        }

        set {
            objc_setAssociatedObject(self, &UIControl.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    func addTargetAction
    (for controlEvent:UIControl.Event,action:@escaping Action) {
        let target = ControlTarget(action: action)
        self.controlTargets.append(target)
        self.addTarget(target, action: target.actionSel, for: controlEvent)
    }
}
