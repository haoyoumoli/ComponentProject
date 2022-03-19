//
//  ControlContainer.swift
//  AttributeTextDemo
//
//  Created by apple on 2021/11/15.
//

import UIKit

//MARK: 初始化
class BuilderControl:UIControl {
    
    //状态监听器
    typealias StateChangedHandler = (_ controlContainer:BuilderControl,_ state:Bool) -> Void
    var isSelectedChangedHandler:StateChangedHandler? = nil
    override var isSelected: Bool {
        didSet { isSelectedChangedHandler?(self,isSelected) }
    }
    
    var isHighligtedChangedHandler:StateChangedHandler? = nil
    override var isHighlighted: Bool {
        didSet { isHighligtedChangedHandler?(self,isHighlighted)}
    }
    
    var isEnabledChangedHandler:StateChangedHandler? = nil
    override var isEnabled: Bool {
        didSet { isEnabledChangedHandler?(self,isEnabled)}
    }
    
    //手势事件处理器
    var touchEventListener:TouchEventListener? = nil
    
    //布局被调用
    var layoutSubviewsHandler:((_ controlContainer:BuilderControl)->Void)? = nil
    
    init(viewBuilder:(BuilderControl)->Void) {
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

//MARK: - 将所有子view禁用事件接受
extension BuilderControl {
    //这个方法用来处理点击子view区域addtarget不能被触发
    func setIsUserEnableForSubViews(_ isEnable:Bool) {
        subviews.forEach { v in
            v.isUserInteractionEnabled = isEnable
        }
    }
}

//MARK: - 布局更新
extension BuilderControl {
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSubviewsHandler?(self)
    }
}


//MARK: - Touches
extension BuilderControl {
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
