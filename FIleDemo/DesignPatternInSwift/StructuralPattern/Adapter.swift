//
//  Adapter.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/19.
//

import Foundation

protocol NewDeathSuperLaserAiming {
    var angleV: Double { get }
    var angleH: Double { get }
}


struct OldDeathStarSuperlaserTarget {
    let angleHorizontal: Float
    let angleVertical: Float
    
    init(angleHorizontal: Float,angleVertical: Float) {
        self.angleHorizontal = angleHorizontal
        self.angleVertical = angleVertical
    }
}

struct NewDeathStarSuperlaserTarget: NewDeathSuperLaserAiming {
    var angleV: Double {
        return Double(target.angleVertical)
    }
    
    var angleH: Double {
        return Double(target.angleHorizontal)
    }
    
    
    private let target:OldDeathStarSuperlaserTarget
    
    init(_ target: OldDeathStarSuperlaserTarget) {
        self.target = target
    }
    
}

func testAdapter() {
    let target = OldDeathStarSuperlaserTarget(angleHorizontal: 14.0, angleVertical: 12.0)
    let newFormat = NewDeathStarSuperlaserTarget(target)
    debugPrint((newFormat.angleH,newFormat.angleV))
}
