//
//  ProtectionProxy.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/20.
//

import Foundation

///保护代理模式（Protection Proxy）
///在代理模式中，创建一个类代表另一个底层类的功能。 保护代理用于限制访问


protocol DoorOpening {
    func open(doors: String) -> String
}

final class HAL9000: DoorOpening {
    func open(doors: String) -> String {
        return ("HAL9000: Affirmative, Dave. I read you. Opened \(doors).")
    }
}


final class CurrentComputer:DoorOpening {

    func authenticate(password: String) -> Bool {
        guard password == "pass" else {
            return false
        }
        
        computer = HAL9000()
        
        return true
    }
    
    private var computer: HAL9000!
    
    func open(doors: String) -> String {
        guard computer != nil else {
            return "Access Denied. I'm afraid I can't do that."
        }
        
        return computer.open(doors: doors)
    }
}

func testProtectionProxy() {
    let computer = CurrentComputer()
    let podBay = "Pod Bay Doors"
    
   _ = computer.open(doors: podBay)
    
   _ = computer.authenticate(password: "pass")
   _ = computer.open(doors: podBay)
    
}
