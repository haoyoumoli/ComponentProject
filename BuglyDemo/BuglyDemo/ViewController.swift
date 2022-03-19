//
//  ViewController.swift
//  BuglyDemo
//
//  Created by apple on 2022/3/15.
//

import UIKit


fileprivate var _oldHanlder:((NSException) -> Void)? = nil


func exceptiongHanlder(_ exception:NSException) {
    debugPrint("exceptiongHanlder")
    _oldHanlder?(exception)
}

func signalHandler(_ signal:Int32) {
    debugPrint("signalHandler(\(signal))")
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        startCrashListening()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        testArrayIndexOutOfRange()
    }
}

//MARK:  - private
extension ViewController {
    
    func startCrashListening() {
        _oldHanlder = NSGetUncaughtExceptionHandler()
        NSSetUncaughtExceptionHandler(exceptiongHanlder(_:))
        
        //程序异常退出
        signal(SIGABRT, signalHandler(_:))
        //无效内存引用
        signal(SIGSEGV, signalHandler(_:))
        //
        signal(SIGBUS, signalHandler(_:))
        //陷阱
        signal(SIGTRAP, signalHandler(_:))
        // 非法函数映象
        signal(SIGILL, signalHandler(_:))
        // 终止信号
        signal(SIGTERM, signalHandler(_:))
        
        signal(SIGQUIT, signalHandler(_:))

    }
    
    func testArrayIndexOutOfRange() {
//       let arr = [1]
//        //BOOM!!!
//        let value = arr[2]
//        debugPrint(value)
       
        
//        let arr:NSArray = NSArray.init(array: [2])
//        debugPrint(arr[1])
        
//        for i in 0..<2 {
//            let v = 1 / i
//            debugPrint(v)
//        }
        
        self.perform(NSSelectorFromString("aaz"))
        
      
    }
}


