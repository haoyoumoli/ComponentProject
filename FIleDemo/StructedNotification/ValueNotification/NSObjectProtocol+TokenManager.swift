//
//  NSObjectProtocol+TokenManager.swift
//  BtreeMaster
//
//  Created by apple on 2021/7/22.
//

import Foundation

public extension NSObjectProtocol {
    func addTo(tokenManager: NotificationTokenManager) {
        tokenManager.addToken(self)
    }
}
