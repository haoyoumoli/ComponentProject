//
//  UserServiceInterface.swift
//  UserSerivce
//
//  Created by apple on 2022/2/14.
//

import Foundation
import ModuleManager
import UIKit

public protocol UserServiceInterface {
    
    func goToLoginVc(from:UIViewController, completion:@escaping (Error?) -> Void)
    
    /// 查询是否为vip
    func getIsVip(completion: @escaping (Bool)->Void)
}

public class UserService:Module {
    
    public required init(parameter: Any) {
        debugPrint("UserService init")
    }
    
    deinit {
        debugPrint("UserService deinit")
    }
    
    public func getInterfaceImpl() -> Any {
        return self
    }
    
   
}

extension UserService: UserServiceInterface {
    public func goToLoginVc(
        from: UIViewController,
        completion: @escaping (Error?) -> Void)
    {
        
    }
    
    public func getIsVip(completion: (Bool) -> Void) {
        debugPrint(#function)
        //BlaBlaBla....
        completion(false)
    }
}
