//
//  DefaultValues.swift
//  PropertyCodeableDemo
//
//  Created by apple on 2021/5/17.
//

import Foundation

///bool类型的包装器
///使用 @Default.True or @Default.false
extension Default {
    typealias True = Default<Bool.True>
    typealias False = Default<Bool.False>
}

//String类型包装器
///使用 @Default.EmptyString
extension Default {
    typealias EmptyString = Default<String.Empty>
}


