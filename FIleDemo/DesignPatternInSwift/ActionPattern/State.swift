//
//  State.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/18.
//

import Foundation

//状态
//在状态模式中，对象的行为是基于它的内部状态而改变的。 这个模式允许某个类对象在运行时发生改变。


protocol State {
    func isAuthorized(context: Context) -> Bool
    func userId(context:Context) -> String?
}


final class UnauthrizedState: State {
    func isAuthorized(context: Context) -> Bool {
        return false
    }
    
    func userId(context: Context) -> String? {
        return nil
    }
}

final class AuthorizedState: State {
    
    
    let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func isAuthorized(context: Context) -> Bool {
        return true
    }
    
    func userId(context: Context) -> String? {
        return userId
    }
}

final class Context {
    var state:State = UnauthrizedState()
    
    var isAuthorized: Bool {
        get {
            return state.isAuthorized(context: self)
        }
    }
    
    var userId: String? {
        get {
            return state.userId(context: self)
        }
    }
    
}

func testState() {
    
    let userContext = Context()
    debugPrint((userContext.isAuthorized,userContext.userId))
    
    userContext.state = AuthorizedState(userId: "admin")
    debugPrint((userContext.isAuthorized,userContext.userId))
}
