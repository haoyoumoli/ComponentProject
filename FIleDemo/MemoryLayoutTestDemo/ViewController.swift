//
//  ViewController.swift
//  MemoryLayoutTestDemo
//
//  Created by apple on 2021/10/26.
//

import UIKit

struct S1
{
    let v1:UInt8
    let v2:UInt8
    let v3:UInt8
    let v4:UInt8
    let v5:UInt8
    let v6:UInt8
} //6

struct S2 {
    let v1:UInt8
    let v2:UInt32
    let v3:UInt8
} //12个字节

struct S3 {
    let v1:UInt8
    let v2:UInt16
    let v3:UInt32
    let v4:UInt64
} // 16个字节


class C1 {
    let v1:UInt8
    let v2:String
    
    init(v1:UInt8,v2:String) {
        self.v1 = v1
        self.v2 = v2
    }
    
}

extension MemoryLayout {
    static func infoDebugPrint() {
        debugPrint("\(T.self).stride:\(stride)")
        debugPrint("\(T.self).size:\(size)")
        debugPrint("\(T.self).alignment:\(alignment)")
        debugPrint()
    }
}

///c结构体依然可以用扩展添加方法
extension CStruct1 {
    mutating func changeValues() {
        v1 = 255
        v2 = 256
        v3 = 0
    }
}
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        MemoryLayout<S1>.infoDebugPrint()
        MemoryLayout<S2>.infoDebugPrint()
        MemoryLayout<S3>.infoDebugPrint()
        MemoryLayout<C1>.infoDebugPrint()
        MemoryLayout<CStruct1>.infoDebugPrint()
        
        
        var cstruct = CStruct1.init(v1: 0, v2: 0, v3: 0)
        cstruct.changeValues()
        
        
        let values:[UInt8] = [1,2,3,4,5,6]
        
        values.withUnsafeBytes { pointer in
            let s1 = pointer.bindMemory(to: S1.self).baseAddress!.pointee
            let s2 = pointer.bindMemory(to: S2.self).baseAddress!.pointee
            debugPrint(s1)
            debugPrint(s2)
        }
        
        
        for i in 0..<10 {
            FileHandle.appendContent(filePath: "/Users/apple/Desktop/test.txt", content: "test\(i)")
        }
      
    
    }


}

