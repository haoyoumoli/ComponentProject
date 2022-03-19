//
//  VerticalLayoutable+Ext.swift
//  LayoutDemo2
//
//  Created by apple on 2021/8/9.
//

import Foundation
import UIKit


//MARK: - NSAttributedString

class AttributeStringLayout: LayoutItem<NSAttributedString> {
   
    override func layoutForWidth(_ width: CGFloat) -> Self {
        guard let d = getData() else {
            self.frame = .zero
            return self
        }
        
        let size = d.boundingRect(with: .init(width: width, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin,.usesFontLeading], context: nil)
        
        self.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        return self
    }
}

//MARK: - String
class StringLayout: LayoutItem<String> {

    var font:UIFont = .systemFont(ofSize: 15.0)
    
    var color: UIColor = .black
    

    override func layoutForWidth(_ width: CGFloat) -> Self {
        guard let d = getData(),d.isEmpty == false else {
            self.frame = .zero
            return self
        }
        
        let attributeStr = NSAttributedString.init(string: d, attributes: [NSAttributedString.Key.font:self.font,.foregroundColor:self.color])
        
        let layout = AttributeStringLayout(data: attributeStr)
        self.frame = layout.layoutForWidth(width).getFrame()
        return self
    }
}


//MARK: -
extension UILabel {
    func displayLayout(_ layout:AttributeStringLayout) {
        self.attributedText = layout.getData()
        self.numberOfLines = 0
        self.frame = layout.frame
    }
    
    func displayLayout(_ layout:StringLayout) {
        self.text = layout.getData()
        self.numberOfLines = 0
        self.font = layout.font
        self.frame = layout.frame
    }
}


extension UITextView {
    func displayLayout(_ layout:AttributeStringLayout) {
        self.attributedText = layout.getData()
        self.frame = layout.frame
    }
    
    func displayLayout(_ layout:StringLayout) {
        self.text = layout.getData()
        self.font = layout.font
        self.frame = layout.frame
    }
}






