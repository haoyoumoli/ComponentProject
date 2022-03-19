//
//  SentryHelper.swift
//  BuglyDemo
//
//  Created by apple on 2022/3/16.
//

import Foundation
import Sentry

class SentryHelper {
    
    static
    func start() {
        SentrySDK.start(options: [:])
    }
}
