//
//  LoginViewModel.swift
//  CombineDemo
//
//  Created by apple on 2021/6/11.
//

import Foundation
import Combine

class LoginViewModel {
    var cancelanble = Set<AnyCancellable>()
    
    typealias StringInput = AnyPublisher<String,Never>
    
    init(username:StringInput,
         password:StringInput,
         loginAction:AnyPublisher<Void,Never>) {
        
        let validingUserNamed = PassthroughSubject<Bool,Never>()
        validingUserName = validingUserNamed.eraseToAnyPublisher()
        
        ///缓存账户的验证结果
        let cache = NSCache<NSString, NSNumber>.init()
        
        userNameIsValid = username
            .filter({ $0.count > 3 })
            ///500ms外的操作会执行
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            ///移除相同的项目
            .removeDuplicates()
            .flatMap({
                v  -> Future<Bool,Never> in
                
                return Future<Bool,Never>.init { promise in
                    
                    validingUserNamed.send(true)
                    
                    if let result = cache.object(forKey: v as NSString) as NSNumber? {
                        validingUserNamed.send(false)
                        promise(.success(result.boolValue))
                        return
                    }
                    
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                        validingUserNamed.send(false)
                        let isValid = !(v == "12345")
                        cache.setObject(NSNumber(booleanLiteral:isValid ), forKey: v as NSString)
                        promise(.success(isValid))
                    }
                }
            })
            .share()
            .eraseToAnyPublisher()
       
        
        let userNameAndPasswordInputValid = Publishers.CombineLatest4.init(username,password,userNameIsValid,validingUserName)
        
        ///登录按钮是否可以点击
        loginIsEnabled = userNameAndPasswordInputValid
            .map({
                return ($0.0.count > 3 && $0.1.count > 4 && $0.2 && !$0.3)
            })
            .share()
            .eraseToAnyPublisher()
        
    
        let logingingd = PassthroughSubject<Bool,Never>()
        
        ///是否正在登录
        isLogining = logingingd.share().eraseToAnyPublisher()
        
        let currentValSubject = CurrentValueSubject<(String,String),Never>.init(("",""))
        
        ///使用currentValSubject 缓存最新的用户名和密码
         username.combineLatest(password)
            .subscribe(currentValSubject)
            .store(in: &cancelanble)
        
        
        ///是否正在登录
        callLogin = loginAction
            .flatMap({
                _ in
                return Just.init(currentValSubject.value)
            })
            .flatMap({ (v) -> Future<Bool,Never> in
                ///模拟登陆
                ///没有找到更好的方法获取用户名和密码
                debugPrint(v)
                return Future<Bool,Never>.init({
                    promise in
                    logingingd.send(true)
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                        promise(.success(v.0 == "123456" && v.1 == "123456"))
                        logingingd.send(false)
                    }
                })
            })
            .share()
            .eraseToAnyPublisher()
    }
    
    
    deinit {
        debugPrint("LoginViewModel deinit")
    }
    
    //MARK: outputs
    ///用户名是否有效
    let userNameIsValid:AnyPublisher<Bool,Never>
    
    ///是否正在验证用户名
    let validingUserName: AnyPublisher<Bool,Never>
    
    ///是否可以登录
    let loginIsEnabled:AnyPublisher<Bool,Never>
    
    ///是否正在进行登录
    let isLogining:AnyPublisher<Bool,Never>
    
    ///调用登录后的结果
    let callLogin:AnyPublisher<Bool,Never>
}
