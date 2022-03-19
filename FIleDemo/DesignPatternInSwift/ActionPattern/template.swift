//
//  template.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/18.
//

import Foundation

protocol Garden {
    func prepareSoil()
    func plantSeeds()
    func waterPlants()
    func prepareGarden()
}

extension Garden {
    func prepareGarden() {
        prepareSoil()
        plantSeeds()
        waterPlants()
    }
}

final class RoseGarden: Garden {
    
    func prepareSoil() {
        print("prepare soil for rose garden")
    }
    
    func plantSeeds() {
        print("plant seeds for rose garden")
    }
    
    func waterPlants() {
        print("water the rose garden")
    }
    
    func prepare() {
        prepareGarden()
    }
}

func testRoseGarden() {
    let roseGarden = RoseGarden()
    roseGarden.prepare()
}
