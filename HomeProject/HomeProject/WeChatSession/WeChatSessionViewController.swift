//
//  WeChatSessionViewController.swift
//  HomeProject
//
//  Created by apple on 2022/3/19.
//

import UIKit

class WeChatSessionViewController: UIViewController {
    
    private(set)
    var listModels = [ListModel<CellType, Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}

//MARK: -
extension WeChatSessionViewController {
    enum CellType {
        case text
        case image
        case audio
    }
    
}

//MARK: -
private
extension WeChatSessionViewController {
    
}
