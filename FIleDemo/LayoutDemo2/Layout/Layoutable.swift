//
//  Layoutable.swift
//  LayoutDemo2
//
//  Created by apple on 2021/8/9.
//

import Foundation
import UIKit



protocol Layoutable {

    @discardableResult
    func layoutForWidth(_ width:CGFloat) -> Self
    
    @discardableResult
    func setOffset(dx:CGFloat,dy:CGFloat) -> Self
    
    func getFrame() -> CGRect
}




