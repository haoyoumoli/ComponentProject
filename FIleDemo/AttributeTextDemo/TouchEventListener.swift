//
//  TouchEventListener.swift
//  AttributeTextDemo
//
//  Created by apple on 2021/11/15.
//

import UIKit

class TouchEventListener {
    
    enum State{
        case began
        case moved
        case ended
        case cancelled
    }
    
    typealias TouchedHandler = (_ state:State,_ touches: Set<UITouch>,_  event: UIEvent?) -> Bool
    
    let touchesHandler:TouchedHandler
    
    init(handler:@escaping TouchedHandler) {
        self.touchesHandler = handler
    }
}
