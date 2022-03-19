//
//  Strategy.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/18.
//

import Foundation

//策略模式
//对象有某个行为，但是在不同的场景中，该行为有不同的实现算法。策略模式：
//
//定义了一族算法（业务规则）；
//封装了每个算法；
//这族的算法可互换代替（interchangeable）。

struct TestSubject {
    let pupliDiameter: Double
    let blushResponse: Double
    let isOrganic: Bool
}

protocol RealnessTesting: AnyObject {
    func testRealness(_ testSubject: TestSubject) -> Bool
}

final class VoightKampffTest: RealnessTesting {
    func testRealness(_ testSubject: TestSubject) -> Bool {
        return testSubject.pupliDiameter < 30.0 || testSubject.blushResponse == 0.0
    }
}


final class GeneticTest: RealnessTesting {
    func testRealness(_ testSubject: TestSubject) -> Bool {
        return testSubject.isOrganic
    }
}

final class BladeRunner {
    private let strategy: RealnessTesting
    
    init(test: RealnessTesting) {
        self.strategy = test
    }
    
    func testIfAndroid(_ testSubject:TestSubject) -> Bool {
        return !strategy.testRealness(testSubject)
    }
}

func testStrategy() {
    let rachel = TestSubject(pupliDiameter: 30.2, blushResponse: 0.3, isOrganic: false)
    
    // Deckard is using a traditional test
    let deckard = BladeRunner(test: VoightKampffTest())
    let isRacheAndroid = deckard.testIfAndroid(rachel)
    
    // Gaff is using a very precise method
    // Gaff is using a very precise method
    let gaff = BladeRunner(test: GeneticTest())
    let isDeckardAndroid = gaff.testIfAndroid(rachel)
    
    debugPrint(#function,(isRacheAndroid,isDeckardAndroid))
}
