//
//  Facade.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/20.
//

import Foundation

///外观模式
///外观模式为子系统中的一组接口提供一个统一的高层接口，使得子系统更容易使用

final class Defaults {
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    subscript(key:String) -> String? {
        get {
            return defaults.string(forKey: key)
        }
        
        set {
            defaults.setValue(newValue, forKey: key)
        }
    }
}


func testFacade() {
    
    let storage = Defaults()
    
    // Store
    storage["Bishop"] = "Disconnect me. I’d rather be nothing"
    
    // Read
   debugPrint( storage["Bishop"] ?? "")
}
