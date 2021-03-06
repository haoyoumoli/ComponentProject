//
//  Memmento.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/18.
//

import Foundation

///备忘录
/// 在不破坏封装性的前提下，捕获一个对象的内部状态，并在该对象之外保存这个状态。这样就可以将该对象恢复到原先保存的状态

///观察者
///就不写了,比较熟悉

typealias Memento = [String:String]

protocol MementoConvertible {
    
    var memento: Memento { get }
    
    init?(memento: Memento)
}

struct GameState {
    
    var chapter: String
    var weapon: String
    
    init(chapter: String, weapon: String) {
        self.chapter = chapter
        self.weapon = weapon
    }
}

extension GameState:MementoConvertible {
    
    private enum Keys {
           static let chapter = "com.valve.halflife.chapter"
           static let weapon = "com.valve.halflife.weapon"
    }
    
    init?(memento: Memento) {
        guard let mementoChapter = memento[Keys.chapter],
                     let mementoWeapon = memento[Keys.weapon] else {
                   return nil
               }
        
        self.init(chapter: mementoChapter, weapon: mementoWeapon)
    }
    
    var memento: Memento {
        return [Keys.chapter: chapter, Keys.weapon: weapon ]
    }
}


enum CheckPoint {
    private static let defaults = UserDefaults.standard
    
    static func save(_ state:MementoConvertible,saveName:String) {
        defaults.set(state.memento, forKey: saveName)
        defaults.synchronize()
    }
    
    static func restore(saveName:String) -> Any? {
        return defaults.object(forKey: saveName)
    }
}


func testMemento()  {
    var gameState = GameState(chapter: "Black Mesa Inbound", weapon: "Crowbar")
    
    gameState.chapter = "Anomalous Materials"
    gameState.weapon = "Glock 17"
    CheckPoint.save(gameState, saveName: "gameState1")

    gameState.chapter = "Unforeseen Consequences"
    gameState.weapon = "MP5"
    CheckPoint.save(gameState, saveName: "gameState2")
    
    gameState.chapter = "Office Complex"
    gameState.weapon = "Crossbow"
    CheckPoint.save(gameState, saveName: "gameState3")
    
    if let memento = CheckPoint.restore(saveName: "gameState1") as? Memento {
        let finalState = GameState(memento: memento)
        dump(finalState)
    }
}
