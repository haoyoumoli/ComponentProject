//
//  VirtualProxy.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/20.
//

import Foundation

///虚拟代理
///在代理模式中，创建一个类代表另一个底层类的功能。 虚拟代理用于对象的需时加载。


protocol HEVSuitMedicalAid {
    func adminusterMorphine() -> String
}


final class HEVSuit: HEVSuitMedicalAid {
    func adminusterMorphine() -> String {
        return "Morphine administered."
    }
}


final class HEVSuitHumanInterface: HEVSuitMedicalAid {
    lazy private var physicalSuit: HEVSuit = HEVSuit()
    
    func adminusterMorphine() -> String {
        return physicalSuit.adminusterMorphine()
    }
}

func testVirtualProxy() {
    let humanInterface = HEVSuitHumanInterface()
   let ss = humanInterface.adminusterMorphine()
   debugPrint(ss)
}
