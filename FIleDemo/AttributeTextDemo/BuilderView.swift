//
//  BuilderView.swift
//  AttributeTextDemo
//
//  Created by apple on 2021/11/16.
//

import UIKit

//MARK: 成员初始化
class BuilderView:UIView {
    //手势事件处理器
    var touchEventListener:TouchEventListener? = nil
    
    //布局被调用
    var layoutSubviewsHandler:((_ builderView:BuilderView)->Void)? = nil
    
    init(viewBuilder:(BuilderView)->Void) {
        super.init(frame: .zero)
        viewBuilder(self)
    }
    
    override convenience init(frame: CGRect) {
        self.init(viewBuilder: {_ in })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: - 布局更新
extension BuilderView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSubviewsHandler?(self)
    }
}
//MARK: - 手势事件
extension BuilderView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if (touchEventListener?.touchesHandler(.began,touches,event) ?? true) == true {
            super.touchesBegan(touches, with: event)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (touchEventListener?.touchesHandler(.moved,touches,event) ?? true) == true {
            super.touchesMoved(touches, with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (touchEventListener?.touchesHandler(.ended,touches,event) ?? true) == true {
            super.touchesEnded(touches, with: event)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (touchEventListener?.touchesHandler(.cancelled,touches,event) ?? true) == true {
            super.touchesCancelled(touches, with: event)
        }
    }
}
