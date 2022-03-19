//
//  ViewController.swift
//  AddressBookDemo
//
//  Created by apple on 2021/11/30.
//

import UIKit
import CallKit

typealias ValueChanged<T> = (T) -> Void

struct ValueWrapper<T> {
   var value:T {
        didSet {
            valueObserver?(value)
        }
    }
    
    init (value:T) {
        self.value = value
    }
    
    var valueObserver:ValueChanged<T>?

}


class OOO {
    var pStr = ValueWrapper(value: "")
    
    
    var stringOB: ValueChanged<String>?
    
    
    func aaa() {
        pStr.value = "asdf"
        pStr.valueObserver = {
            v in
            debugPrint(v)
        }
    }
    
    deinit {
        stringOB?("哈哈")
        debugPrint("OOO:\(self) deinit")
    }
}






class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var threadCount:[Int:Bool] = [:]
//        debugPrint("\(AsyncTaskPerformer.shared.countOfCpu)")
//        for _ in 0..<100 {
//            AsyncTaskPerformer.shared.perform {
//                let thread = Thread.current
//                threadCount[thread.c] = true
//                debugPrint(Thread.current,OOO())
//            }
//
//        }
 
       
        
        
    }


}

class CustomCallDirectoryProvider:CXCallDirectoryProvider {
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        let labelKeyedByPhoneNumer: [CXCallDirectoryPhoneNumber:String] = [
            +8618346846350:"张三"
        ]
        for (phoneNumber,label) in labelKeyedByPhoneNumer.sorted(by: <)
        {
            //添加阻止列表
            context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
            
            //添加识别列表
            context.addIdentificationEntry(withNextSequentialPhoneNumber: phoneNumber, label: label)
        }
    }
}
