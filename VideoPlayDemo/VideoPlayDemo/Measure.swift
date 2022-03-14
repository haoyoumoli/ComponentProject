//
//  Measure.swift
//  VideoPlayDemo
//
//  Created by apple on 2022/3/14.
//

import Foundation

func measure(_ label:String = "" , _ block:() -> Void) {
    let start = Date().timeIntervalSince1970
    block()
    let end = Date().timeIntervalSince1970
    debugPrint("\(label) measure result:\(end - start)")
   
}

func asyncMeasure(_ label:String = "", _ block:@escaping (@escaping ()->Void) -> Void) {
    let start = Date().timeIntervalSince1970
    let isFinished = {
        let end = Date().timeIntervalSince1970
        debugPrint("\(label) measure result:\(end - start)")
    }
    block(isFinished)
}
