//
//  ViewController.swift
//  UserProject
//
//  Created by apple on 2022/2/10.
//

import UIKit
import UserSerivce
import ModuleManager

class ViewController: UIViewController {
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userModuleName = "User"
        let m = ModuleManager.shared
        
        //注册用户模块
        m.regsisterModule(for: userModuleName, type: UserService.self, parameter: (),lazy: true)
        
        guard let userImp = m.getInterfaceImp(moduleName: userModuleName, interfaceType: UserServiceInterface.self) else {
            debugPrint("获取User模块接口实现失败")
            return
        }
        userImp.getIsVip { isVip in
            if isVip {
                debugPrint("你是vip")
            } else {
                debugPrint("你不是vip")
            }
        }
        
        m.removeModule(for: userModuleName)
        
        // Do any additional setup after loading the view.
    }


}

