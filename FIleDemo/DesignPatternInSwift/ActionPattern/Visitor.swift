//
//  Visitor.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/18.
//

import Foundation

///访问者
///封装某些作用于某种数据结构中各元素的操作，它可以在不改变数据结构的前提下定义作用于这些元素的新的操作。

protocol Plant {
    func accept(visitor:PlantVisitor)
}


final class MoonJedha: Plant {
    func accept(visitor: PlantVisitor) {
        visitor.visit(plant: self)
    }
}


final class PlanetAlderaan: Plant {
    func accept(visitor: PlantVisitor) {
        visitor.visit(plant: self)
    }
}

final class PlanetCoruscant: Plant {
    func accept(visitor: PlantVisitor) {
        visitor.visit(plant: self)
    }
}

final class PlanetTatooine: Plant {
    func accept(visitor: PlantVisitor) {
        visitor.visit(plant: self)
    }
}



protocol PlantVisitor {
    func visit(plant:Plant)
}


final class NameVisitor: PlantVisitor {
    
    var name = ""
    
    func visit(plant: Plant) {
        switch plant {
        case  _ as PlanetAlderaan:
            name = "Alderaan"
        case  _ as PlanetCoruscant:
            name = "Coruscant"
        case  _ as PlanetTatooine:
            name = "Tatooine"
        case  _ as MoonJedha:
            name = "Jedha"
        default:
            name = "unknown"
        }
    }
}


func testVisitor() {
    
    let plants:[Plant] = [PlanetAlderaan(),PlanetTatooine(),PlanetCoruscant(),MoonJedha()]
    
    let visitor = NameVisitor()
    
    let names = plants.map {
        (plant:Plant) -> String in
        plant.accept(visitor: visitor)
        return visitor.name
    }
    
    debugPrint(names)
}
