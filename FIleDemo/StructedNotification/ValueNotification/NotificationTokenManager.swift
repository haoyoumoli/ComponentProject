//
//  NotiTokenManager.swift
//  BtreeMaster
//
//  Created by apple on 2021/7/22.
//

import Foundation

/// 通知Token管理器
/// 在deinit是从 center 中移除管理的 tokens
public final class NotificationTokenManager {
    
    private(set) var tokens:[NSObjectProtocol] = []
    public let notificationCenter:NotificationCenter
    
    public init(_ notificationCenter:NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }
    deinit {
        debugPrint("NotificationTokenManager.deinit")
        self.removeTokensForNotificationDefaultCenter()
    }
}


//MARK: 通知Token管理
extension NotificationTokenManager {
    
    /// 将token 添加的管理列表中
    func addToken(_ token:NSObjectProtocol) {
        tokens.append(token)
    }
        
    ///从管理列表中移除token
    func removeToken( _ token:NSObjectProtocol) {
        tokens.removeAll(where: { $0 === token})
    }
    
    func removeTokensForNotificationDefaultCenter() {
        tokens.forEach({self.notificationCenter.removeObserver($0)})
        tokens.removeAll()
    }
}



