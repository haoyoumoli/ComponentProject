//
//  HookTestClasses.swift
//  TableViewTouchStatisticsDemo
//
//  Created by apple on 2021/10/29.
//

import Foundation

fileprivate func hookMethod(for cls:AnyClass, originalSel:Selector,swizzledSel:Selector) -> Bool {
    
    guard
        let originalMethod = class_getInstanceMethod(cls, originalSel),
        let swizzledMethod = class_getInstanceMethod(cls, swizzledSel)
    else {
        return false
    }
    //尝试添加实现,避免交换了父类中方法因此错误
    //注意: 不可以用class_getInstanceMethod方法返回是否为nil来判断当前类是否实现了方法,因为其会向父类中查找实现
    // original selector ---> swizzled method imp
   let addSuccess = class_addMethod(cls, originalSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

    if addSuccess {
       //添加成功,保存之前的实现
       //--> swizzled method imp
        class_replaceMethod(cls, swizzledSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    } else {
        //没有添加成功说明当前类中已经有了 original selector 的实现,
        //这时直接交换
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    return true
}

class HookTestSuper: NSObject {
    @objc
    dynamic public func methodA() {
        debugPrint("HookTestSuper methodA")
    }
}


@objc class HookTestSubA: HookTestSuper {
    
}


class AAA {
    dynamic func wwwMethod() {
        debugPrint(1111)
    }
}


struct BBB {
    dynamic func wwwMethod() {
        debugPrint(1111)
    }
}


extension HookTestSubA {
   public class func installHookMethods() -> Bool {
       return hookMethod(for: self, originalSel: #selector(methodA), swizzledSel: #selector(hook_methodA))
    }
    
    @objc func hook_methodA() {
        debugPrint("HookTestSubA hook_methodA")
        hook_methodA()
    }
}

//do {
//    let v = HookTestSubA.installHookMethods()
//    let m = HookTestSubA()
//    m.methodA()
//}
//
//do {
//    let bbb = BBB()
//    bbb.wwwMethod()
//
//    let aaa = AAA()
//    aaa.wwwMethod()
//}


