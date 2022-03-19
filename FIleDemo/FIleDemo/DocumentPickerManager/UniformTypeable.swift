//
//  UniformTypeable.swift
//  FIleDemo
//
//  Created by apple on 2021/5/14.
//

import Foundation
import UniformTypeIdentifiers

protocol UniformTypeable {
    
    /// 统一类型id,iOS14.0 之前版本使用这个方法
    ///苹果 UniformTypeIdentifiers 网址
    /// https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html
    @available(iOS, introduced: 8.0, deprecated: 14.0)
    var uniformTypeIdentifiers:String? { get }
    
    ///ios14.0 之后使用这个版本
    @available(iOS 14.0, *)
    var utType: UTType? { get }
}
