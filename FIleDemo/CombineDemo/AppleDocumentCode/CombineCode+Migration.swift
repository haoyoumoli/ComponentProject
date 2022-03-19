//
//  CombineCode+Migration.swift
//  CombineDemo
//
//  Created by apple on 2021/6/10.
//

import Foundation
import UIKit
import Combine

//MARK: - Routing Notifications to Combine Subscribers
extension CombineCode {
    
    func orientationDidChangeDemo()  {
        ///使用正常通知的版本
        let _ = NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { noti in
            if UIDevice.current.orientation == .portrait {
                debugPrint("do something for portait")
            }
        }
        
        ///将通知转化为 combine
        _ = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .filter({ _ in UIDevice.current.orientation == .portrait})
            .sink(receiveValue: { _ in print("do something for portait")})
        
    }
}


//MARK: - Replacing Foundation Timers with Timer Publishers

extension CombineCode {
    
    func timerCombineDemo() {
         _ = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .receive(on: DispatchQueue.global())
            .sink(receiveValue: {
                debugPrint($0)
            })
        
    }
}

class UserInfo: NSObject  {
    @objc dynamic var lastLogin: Date = Date(timeIntervalSince1970: 0)
}

//MARK: - Performing Key-Value Observing with Combine

extension CombineCode {
    
    func kvoCombineDemo() {
        
        
        ///kvo
        _ = observe(\.userInfo.lastLogin, changeHandler: {
            object,change in
            print ("lastLogin now \(change.newValue!).")
        })
        
        ///
    
         userInfo.publisher(for: \.lastLogin)
            .sink(receiveValue: { debugPrint("lastlogin date:\($0)")})
            .store(in: &cancelables)
       
    }
}

//MARK: - Using Combine for Your App’s Asynchronous Code
extension CombineCode {
    
    //MARK: Replace Completion-Handler Closures with Futures
    func replaceCompletionHandlerWithFutures() {
        
        ///1. 使用block作为完成处理器
        let completion = { debugPrint("completion handler")}
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion()
        }
        
        ///2. 使用Futures 代替
        let future = Future<Void,Never>.init { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                promise(.success(()))
            }
        }
        
        future
            .sink(receiveValue: { debugPrint("future1") })
            .store(in: &cancelables)
        
        performAsyncActionAsFutureWithParamter()
            .sink(receiveValue: { debugPrint("\($0)")})
            .store(in: &cancelables)
        
    }
    
    ///
    func performAsyncActionAsFutureWithParamter() -> Future<Int,Never> {
        return Future.init { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let rn = Int.random(in: 1...10)
                promise(.success(rn))
            }
        }
    }
    
    //MARK: Replace Repeatedly Invoked Closures with Subjects
    
    func replaceRepeatedlyInvokedClosuresWithSubjects() {
      
        
        ///内部产生事件的subject,不对外暴露
        let privateDoSomethingSubject = PassthroughSubject<Int, Never>()
        
        ///对外暴露的subject
        let publicSubject = privateDoSomethingSubject.eraseToAnyPublisher()
        
        
        ///subject 支持多个订阅者
        publicSubject
            .sink(receiveValue: { debugPrint("publicSubject1: \($0)")})
            .store(in: &cancelables)
        
      
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            privateDoSomethingSubject.send(1)
            
            publicSubject
                .sink(receiveValue: { debugPrint("publicSubject2: \($0)")})
                .store(in: &self.cancelables)
            
            privateDoSomethingSubject.send(2)
            privateDoSomethingSubject.send(3)
        }
    }
    
}
