//
//  ViewController.swift
//  LIve
//
//  Created by apple on 2022/3/28.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debugPrint("注意打印结果差别")
        var value32:UInt32 = 0x12345678 //78 56 34 12
        
        let pointer:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer.allocate(capacity: 4)
        defer { pointer.deallocate() }
        
        withUnsafeBytes(of: &value32) { p in
            let bytesPointer = p.baseAddress!.bindMemory(to: UInt8.self, capacity: MemoryLayout<UInt32>.stride)
            for i in 0..<MemoryLayout<UInt32>.stride {
                pointer[i] = bytesPointer[i]
            }
        }
        debugPrint("内存布局")
        for i in 0..<MemoryLayout<UInt32>.stride {
            debugPrint(NSString(format: "%x", pointer[i]))
        }
        
        //获取位数
        debugPrint("获取对应的位的值")
        let b0 = UInt8((value32 & 0xff000000) >> 24)
        let b1 = UInt8((value32 & 0x00ff0000) >> 16)
        let b2 = UInt8((value32 & 0x0000ff00) >> 8)
        let b3 = UInt8((value32 & 0x000000ff))
        debugPrint(NSString(format: "%x,%x,%x,%x", b0,b1,b2,b3))
        // Do any additional setup after loading the view.
    }


    func dataAndPointerDemo() {
        /**
         0xf1 = 241 = 1111_1000
         0x12 = 18  = 0001_0010
         */
        var datas:[UInt8] = [0xf1,0x12]
     
        var stream = Data.init(bytes: &datas, count: datas.count)
        
        var pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: datas.count)
        stream.copyBytes(to: pointer, count: datas.count)
        
        defer {
            pointer.deinitialize(count: datas.count)
            pointer.deallocate()
        }
        
        pointer[1] = 0xfe
        //下面两种遍历方式.得到不同的结果
//        do {
//            ///1. 结果错误
//            let bPointer = stream.withUnsafeMutableBytes {
//                return $0.baseAddress!.bindMemory(to: UInt8.self, capacity: datas.count)
//            }
//            for i in 0..<datas.count {
//                debugPrint(bPointer[i])
//            }
//
//            ///2.
//            /// 结果正确
//            stream.withUnsafeMutableBytes { pointer in
//                let bytesPointer = pointer.baseAddress!.bindMemory(to: UInt8.self, capacity: datas.count)
//                for i in 0..<datas.count {
//                    debugPrint(bytesPointer[i])
//                }
//            }
//        }
        
        stream.withUnsafeMutableBytes { pointer in
            let bytesPointer = pointer.baseAddress!.bindMemory(to: UInt8.self, capacity: datas.count)
            bytesPointer[0] = 0xff
            for i in 0..<datas.count {
                debugPrint(bytesPointer[i])
            }
        }
       
        
       
     
        for i in 0..<datas.count {
            debugPrint(pointer[i])
        }
      
        debugPrint(datas,stream)
    }
    
}




