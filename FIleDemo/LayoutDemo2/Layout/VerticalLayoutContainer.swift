//
//  VerticalLayoutBox.swift
//  LayoutDemo2
//
//  Created by apple on 2021/8/9.
//

import Foundation
import UIKit

///从上到下排列的布局
final class VerticalLayoutContainer:LayoutItem<[Layoutable]> {
    
    var spacing:CGFloat = 10.0
    
    override func layoutForWidth(_ width: CGFloat) -> Self {
        guard let d = getData(),d.isEmpty == false else {
            frame = .zero
            return self
        }
        
        var yBaseLine:CGFloat = 0
        for i in d {
            i.layoutForWidth(width)
                .setOffset(dx: 0, dy: yBaseLine)
            
            yBaseLine  = i.getFrame().maxY + spacing
        }
        
        frame = CGRect(x: 0.0, y: 0.0, width: width, height: yBaseLine)
        return self
    }
    
    
    @discardableResult
    override func setOffset(dx: CGFloat, dy: CGFloat) -> Self {
        guard let d = getData(),d.isEmpty == false else {
            frame = .init(x: dx, y: dy, width: .zero, height: .zero)
            return self
        }
        
        var yBaseLine:CGFloat = dy
        for i in d {
            i.setOffset(dx: dx, dy: yBaseLine)
            yBaseLine  = i.getFrame().maxY + spacing
        }
        
        frame = CGRect(x: dx, y: dy, width: frame.width, height: yBaseLine)
        
        return self
    }
}


