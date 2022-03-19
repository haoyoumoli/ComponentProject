//
//  BuglyHelper.swift
//  BuglyDemo
//
//  Created by apple on 2022/3/15.
//

import Foundation
import Bugly

struct BuglyHelper {
    
    
    static func start() {
      //  Bugly.start(withAppId: "dc21c3935e")
        
        let config = BuglyConfig()
        config.debugMode = true
        Bugly.start(withAppId: "dc21c3935e", developmentDevice: true, config: config)
    }
}
