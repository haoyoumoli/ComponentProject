//
//  measure.swift
//  FakeJD
//
//  Created by apple on 2021/3/16.
//

import Foundation

func printCost(label:String,block:()->Void) {
    let date1 = Date()
    block()
    debugPrint(label,"cost",Date().timeIntervalSince(date1))
}
