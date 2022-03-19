//
//  TestNotification.swift
//  BtreeMaster
//
//  Created by apple on 2021/7/22.
//

import Foundation

/// 更结构化的通知,封装userInfo传参
/// 减少由于userInfo 弱类型带来的编程错误
public protocol ValueNotification {
    associatedtype Value
    
    /// 通知的名称
    static var name:Notification.Name { get }
    
    /// 创建Notification对象
    /// - Note: 这个方法已经有默认实现,如果要重载此方法,则也必须要重载parse(userInfo:)方法
    /// - Parameters:
    ///   - object: 通知的发送者
    ///   - value: 要发送的数据类型
    static func getNotification(object:Any?,value:Value) -> Notification
    
    
    /// 解析userInfo返回Value
    /// - Note: 这个方法已经有默认实现,如果要重载此方法,则也必须要重载getNotification(object:value:)方法
    /// - Parameter userInfo: Notification的userInfo
    static func parse(userInfo:[AnyHashable:Any]?) -> Value?
    
    
    
    /// 发送通知
    /// - Note: 这个方法已经有默认实现,如果要重载此方法,则也必须要重载addObserver(object obj:, queue: ,using block:) -> NSObjectProtocol方法
    /// - Parameters:
    ///   - object: 通知发出者
    ///   - value: 要发送的值
    static func post(object:Any?,value:Value)
    
    
    /// 监听通知
    /// - Note: 这个方法已经有默认实现,如果要重载此方法,则也必须要重载
    /// post(object:,value:) 方法
    /// - Parameters:
    ///   - obj: 通知的发出者,传 nil 监听所有
    ///   - queue: block执行的队列
    ///   - block: 回调
    static func addObserver(object obj: Any?, queue: OperationQueue?, using block: @escaping (Any?,Value?) -> Void) -> NSObjectProtocol
}


//MARK: - 默认实现
public extension ValueNotification {
    
    static func getNotification(object:Any?,value:Value) -> Notification {
        Notification.init(name: name, object: object, userInfo: ["StructuredNotification.value.key":value])
    }
    
    static func parse(userInfo:[AnyHashable:Any]?) -> Value? {
        return userInfo?["StructuredNotification.value.key"] as? Value
    }
}


public extension ValueNotification {
    
    static func post(object:Any?,value:Value) {
        let noti = getNotification(object: object, value: value)
        NotificationCenter.default.post(noti)
    }
    
    static func addObserver(object obj: Any?, queue: OperationQueue?, using block: @escaping (Any?,Value?) -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: name, object: obj, queue: queue) { noti in
            let value = parse(userInfo: noti.userInfo)
            block(noti.object,value)
        }
    }
}
