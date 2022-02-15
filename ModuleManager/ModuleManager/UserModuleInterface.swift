//
//  UserModuleInterface.swift
//  ModuleManager
//
//  Created by apple on 2022/2/15.
//

import Foundation
import UIKit

public protocol UserModuleInterface {
    
    func goToLoginVc(from:UIViewController, completion:@escaping (Error?) -> Void)
    
    /// 查询是否为vip
    func getIsVip(completion: @escaping (Bool)->Void)
}
