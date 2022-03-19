//
//  YLCustomOperator.swift
//  CustomOperatorDemo
//
//  Created by apple on 2021/10/27.
//

import Foundation


//参考链接 https://blog.csdn.net/yao1500/article/details/80003631

precedencegroup Cascade {
    higherThan:AssignmentPrecedence
    assignment:false   //true 表示赋值运算符
    associativity:left //结合方向: left right none
}

//级联操错符用来配置对象数据
/// 用法见下面: 可以简化 属性的懒加载模式
infix operator ..:Cascade
public func ..<T>(left:T,right: (inout T)->Void) -> T {
    var left = left
    right(&left)
    return left
}

///级联传递运算符
///当left参数为空或者中途某一个环节返回false,则后面的block都不会被调用
///并且最终的返回值会变为nil
///这也是?的含义
infix operator ..?:Cascade
public func ..?<T>(left:T?,right:(inout T)->Bool) -> T? {
    var left = left
    guard left != nil else { return nil }
    if right(&(left!)) == false {
        return nil
    } else {
        return left!
    }
}



