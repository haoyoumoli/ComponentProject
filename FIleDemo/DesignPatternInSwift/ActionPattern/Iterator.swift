//
//  Iterator.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/18.
//

import Foundation

///迭代器

struct Novella {
    let name: String
}


struct Novellas {
    let novellas:[Novella]
}

struct NovellasIterator {
    
    private var current = 0
    private let novellas: [Novella]
    
    init(novellas: [Novella]) {
        self.novellas = novellas
    }
}

extension NovellasIterator: IteratorProtocol {
    
    mutating func next() -> Novella? {
        guard current < novellas.count else { return nil }
        defer { current += 1 }
        return novellas[current]
    }

}

extension Novellas: Sequence {
    func makeIterator() -> NovellasIterator {
        return NovellasIterator(novellas: novellas)
    }
}


func testNovellasIterator() {
    let greatNovellas = Novellas(novellas: [Novella(name: "The Mist")])
    
    for novella in greatNovellas {
        debugPrint("I've read: \(novella)")
    }
}
