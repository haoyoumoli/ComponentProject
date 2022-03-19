//
//  AttributeStringLayout.swift
//  LayoutDemo2
//
//  Created by apple on 2021/8/9.
//

import Foundation
import UIKit


class LayoutItem<D>:Layoutable {
    
    func setData(_ data: D?) {
        self.data = data
    }
    
    func getData() -> D? {
        return self.data
    }
    
    var frame: CGRect = .zero
        
    private var data:D? = nil
    
    init(data:D?) {
        self.data = data
    }
    
    @discardableResult
    func layoutForWidth(_ width: CGFloat) -> Self {
        fatalError("子类实现")
    }

    @discardableResult
    func setOffset(dx: CGFloat, dy: CGFloat) -> Self {
        frame = CGRect(x: dx, y: dy, width: frame.width, height: frame.height)
        return self
    }
    
    func getFrame() -> CGRect {
        return frame
    }
    
}







