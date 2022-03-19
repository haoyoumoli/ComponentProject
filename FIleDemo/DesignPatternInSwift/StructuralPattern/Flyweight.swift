//
//  Flyweight.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/20.
//

import Foundation

///享元（Flyweight）
///使用共享物件，用来尽可能减少内存使用量以及分享资讯给尽可能多的相似物件；它适合用于当大量物件只是重复因而导致无法令人接受的使用大量内存

// 特指咖啡生成的对象会是享元
struct SpecialityCoffee {
    let origin: String
}


protocol CoffeeSearching {
    func search(orgin:String) -> SpecialityCoffee?
}

// 菜单充当特制咖啡享元对象的工厂和缓存
final class Menu: CoffeeSearching {
    
    private var coffeeAvailable: [String: SpecialityCoffee] = [:]
    
    func search(orgin: String) -> SpecialityCoffee? {
        if coffeeAvailable.index(forKey: orgin) == nil {
            coffeeAvailable[orgin] = SpecialityCoffee(origin: orgin)
        }
        return coffeeAvailable[orgin]
    }
}

final class CoffeeShop {
    private var orders:[Int:SpecialityCoffee] = [:]
    private let menu: CoffeeSearching
    
    init(menu:CoffeeSearching) {
        self.menu = menu
    }
    
    func takeOrder(origin: String, table:Int) {
        orders[table] = menu.search(orgin: origin)
    }
    
    func serve() {
        for (table,origin) in orders {
            print("Serving \(origin) to table \(table)")
        }
    }
}


func testFlyweight() {
    let coffeeShop = CoffeeShop(menu: Menu())

    coffeeShop.takeOrder(origin: "Yirgacheffe, Ethiopia", table: 1)
    coffeeShop.takeOrder(origin: "Buziraguhindwa, Burundi", table: 3)

    coffeeShop.serve()
}

