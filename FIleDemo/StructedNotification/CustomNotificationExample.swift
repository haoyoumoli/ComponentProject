//
//  Example.swift
//  BtreeMaster
//
//  Created by apple on 2021/7/22.
//

import Foundation


//MARK: -  自定义类型(只绑定特定的类型)

extension Notification {
        
    ///唱歌通知
    public struct SingSong:ValueNotification {
        public typealias Value = String
        
        public static var name: Notification.Name {
            return Notification.Name.init("Notification.SingSong")
        }
    }
}

//MARK: - 更通用的模式

extension Notification {
    
    ///发送数据的通知
    public struct Post<Value>:ValueNotification {
        public static var name: Notification.Name {
            ///使用Value参与构建通知名称
            let rawValue = "Notification.post.\(Value.self)"
            return Name.init(rawValue)
        }
    }
    
    ///保存数据到本地的通知
    public struct SaveToDisk<Value>:ValueNotification {
     
        public static var name: Notification.Name {
            ///使用Value参与构建通知名称
            let rawValue = "Notification.SaveToDisk.\(Value.self)"
            debugPrint(rawValue)
            return Name.init(rawValue)
        }
    }
}


