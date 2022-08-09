//
//  YLTextField.swift
//  DDD
//
//  Created by apple on 2022/7/28.
//

import Foundation
import UIKit


class YLTextField:UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
   lazy private var storeString:String = ""
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.becomeFirstResponder()
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        ctx.addRect(bounds)
        ctx.setFillColor(self.backgroundColor?.cgColor ?? UIColor.white.cgColor)
        ctx.fillPath()
        let attributeString = NSAttributedString.init(string: storeString)
        let textRect = attributeString.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesFontLeading, context: nil)
        attributeString.draw(in: .init(x: bounds.width - textRect.width, y: (bounds.height - textRect.height) * 0.5, width: textRect.width, height: textRect.height))
    }
}

//MARK
extension YLTextField:UIKeyInput {
    var hasText: Bool {
        debugPrint(#function,storeString)
        return !storeString.isEmpty
    }
    
    func insertText(_ text: String) {
        debugPrint(#function,storeString)
        storeString.append(text)
        setNeedsDisplay()
    }
    
    func deleteBackward() {
        debugPrint(#function,storeString)
        if storeString.isEmpty == false {
            storeString = String(storeString.prefix(upTo: storeString.index(before: storeString.endIndex)))
            setNeedsDisplay()
        }
    }
    
}


//MARK: - private
extension YLTextField {
    func commonInit() {
        
    }
}
