//
//  Demos.swift
//  ArchivalAndSerializationDemos
//
//  Created by apple on 2022/2/17.
//

import Foundation


//序列化反序列化 Farm
func demo1() {
    let farm = Farm(
        name: "Old MacDonald's Farm",
        location: .init(latitude: 51.132, longitude: 0.2656),
        animals: [.chicken,.dog,.cow,.turkey,.chicken,.dog,.cow,.turkey])
    do {
       let payload:Data = try JSONEncoder().encode(farm)
        
        let decodedFarm = try JSONDecoder().decode(Farm.self, from: payload)
        let jsonStr = String.init(data: payload, encoding: .utf8)
        debugPrint(decodedFarm)
        debugPrint(jsonStr as Any)
    } catch let err {
       debugPrint(err)
    }
}


// 序列化反序列化 Record
func demo2() {
    let record = Record.init(id: 123, name: "记录", timestamp: 132132.22)
    
    do {
        let payload = try JSONEncoder().encode(record)
        let str = String(data: payload, encoding: .utf8)!
        let recordDecoded = try JSONDecoder().decode(Record.self, from: payload)
        debugPrint(payload,str,recordDecoded)
    } catch let err {
        debugPrint(err)
    }
}

//遍历枚举的所有情况
func demo3() {
    for d in Animal.allCases {
        print(d)
    }
}
