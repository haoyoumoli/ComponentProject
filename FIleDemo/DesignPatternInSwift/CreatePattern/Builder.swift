//
//  Builder.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/19.
//

import Foundation

///生成器（Builder）
///一种对象构建模式。它可以将复杂对象的建造过程抽象出来（抽象类别），使这个抽象过程的不同实现方法可以构造出不同表现（属性）的对象。


final class DeathStarBuidler {
    var x: Double?
    var y: Double?
    var z: Double?
    
    typealias BuidlerClosure = (DeathStarBuidler) -> Void
    
    init(builder:BuidlerClosure) {
        builder(self)
    }
}

struct DeathStar: CustomStringConvertible{
    let x: Double
    let y: Double
    let z: Double
    
    init?(builder: DeathStarBuidler) {
        if let x = builder.x,
           let y = builder.y,
           let z = builder.z {
            self.x = x
            self.y = y
            self.z = z
        } else {
            return nil
        }
    }
    
    var description: String {
        return "Death Star at (x:\(x) y:\(y) z:\(z))"
    }
}


func testBuilder() {
    
    let empire = DeathStarBuidler {
        $0.x = 0.1
        $0.y = 0.2
        $0.z = 0.3
    }
    
    let deathStar = DeathStar(builder: empire)
    
    debugPrint(deathStar ?? "")
}
