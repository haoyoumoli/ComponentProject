//
//  ViewController.swift
//  MainProject
//
//  Created by apple on 2022/2/10.
//

import UIKit
import HomeComponent
import SnapKit
import ProtocolServiceKit
import ModuleManager

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //主工程首页测试调用module模块接口
        if let userImp = ModuleManager.shared.getInterfaceImp(moduleName: ModuleNames.user, interfaceType: UserModuleInterface.self)  {
            
            userImp.getIsVip { isVip in
                if isVip {
                    debugPrint("你是vip")
                } else {
                    debugPrint("你不是vip")
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let homeViewController = HomeComponent.ViewController()
            self.present(homeViewController, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }


}

