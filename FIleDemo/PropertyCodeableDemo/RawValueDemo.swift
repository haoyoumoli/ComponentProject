//
//  RawValueDemo.swift
//  PropertyCodeableDemo
//
//  Created by apple on 2021/5/17.
//

import Foundation


/// 这种状态表示有一定的扩展性,但是容易不能发现所有的状态
struct StateRawable: RawRepresentable,Decodable {
    
    let rawValue: String
    
    static let streaming = StateRawable(rawValue: "streaming")
    
    static let archived = StateRawable(rawValue: "archived")
}
