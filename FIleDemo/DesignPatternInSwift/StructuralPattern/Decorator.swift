//
//  Decorator.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/19.
//

import Foundation

///修饰（Decorator）
///修饰模式，是面向对象编程领域中，一种动态地往一个类中添加新的行为的设计模式。 就功能而言，修饰模式相比生成子类更为灵活，这样可以给某个对象而不是整个类添加一些功能

///售价
protocol CostHaving {
    var cost: Double { get }
}

///原料
protocol IngredientHaving {
    var ingredients: [String] { get }
}

///饮料数据协议
typealias BeverageDataHaving = CostHaving & IngredientHaving

///咖啡
struct SimpleCoffe: BeverageDataHaving {
    let cost: Double = 1.0
    let ingredients = ["Water","Coffee"]
}

///饮料协议
protocol BeverageHaving: BeverageDataHaving {
    var beverage: BeverageDataHaving { get }
}

///牛奶
struct Milk: BeverageDataHaving {
    var ingredients: [String] {
        return beverage.ingredients + ["Milk"]
    }
    
    let beverage: BeverageDataHaving
    
    var cost: Double {
        return beverage.cost + 0.5
    }
}

///水果Coffee
struct WhipCoffee: BeverageHaving {
    let beverage: BeverageDataHaving
    var cost: Double {
        return beverage.cost + 0.5
    }
    
    var ingredients: [String] {
        return beverage.ingredients + ["Whip"]
    }
}

func teseDecorator() {
    ///这些饮料都有话费 和成分, 而且可以加牛奶和水果
    
    var someCoffee: BeverageDataHaving = SimpleCoffe()
    print("Cost: \(someCoffee.cost); Ingredients: \(someCoffee.ingredients)")
    
    someCoffee = Milk(beverage: someCoffee)
    print("Cost: \(someCoffee.cost); Ingredients: \(someCoffee.ingredients)")
    
    someCoffee = WhipCoffee(beverage: someCoffee)
    print("Cost: \(someCoffee.cost); Ingredients: \(someCoffee.ingredients)")
}
