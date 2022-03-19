//
//  AbstractFactory.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/19.
//

import Foundation

///抽象工厂

///创建型模式是处理对象创建的设计模式，试图根据实际情况使用合适的方式创建对象。基本的对象创建方式可能会导致设计上的问题，或增加设计的复杂度。创建型模式通过以某种方式控制对象的创建来解决问题。


protocol BurgerDescribing {
    var ingredients: [String] { get }
}

struct CheeseBurger: BurgerDescribing {
    let ingredients: [String]
}

protocol BurgerMaking {
    func make() -> BurgerDescribing
}

///工厂方法实现
final class BigKahunaBurger: BurgerMaking {
    func make() -> BurgerDescribing {
        return CheeseBurger(ingredients: ["Chees","Burger","Lettuce","Tomato"])
    }
}

final class JackInTheBox: BurgerMaking {
    func make() -> BurgerDescribing {
        return CheeseBurger(ingredients: ["Cheese", "Burger", "Tomato", "Onions"])
    }
}


///抽象工厂

enum BurgerFatoryType: BurgerMaking {
    case bigKahuna
    case jackInTheBox
    
    func make() -> BurgerDescribing {
        switch self {
        case .bigKahuna:
            return BigKahunaBurger().make()
        case .jackInTheBox:
            return JackInTheBox().make()
        }
    }
}

func testAbstractFactory() {
    let bigKahuna = BurgerFatoryType.bigKahuna.make()
    let jackInTheBox = BurgerFatoryType.jackInTheBox.make()
    
    debugPrint((bigKahuna,jackInTheBox))
}
