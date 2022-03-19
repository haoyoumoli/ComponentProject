//
//  Bridge.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/19.
//

import Foundation

///桥接（Bridge）
///桥接模式将抽象部分与实现部分分离，使它们都可以独立的变化。


protocol Appliance {
    func run()
}

protocol Switch {
    
    var appliance: Appliance { get set }
    
    func turnOn()
}

final class RemoteControl: Switch {
    
    var appliance: Appliance
    init(appliance: Appliance) {
        self.appliance = appliance
    }
    
    func turnOn() {
        self.appliance.run()
    }
}


final class TV: Appliance {
    func run() {
        debugPrint("tv turned on")
    }
}

final class VacuumCleaner: Appliance {
    func run() {
        debugPrint("vacuum cleaner turned on")
    }
}


func testBridge() {
    let tvRem = RemoteControl(appliance: TV())
    tvRem.turnOn()
    
    let fancyVacuumCleanerRemoteControl = RemoteControl(appliance: VacuumCleaner())
    fancyVacuumCleanerRemoteControl.turnOn()
}
