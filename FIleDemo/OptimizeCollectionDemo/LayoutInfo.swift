//
//  LayoutInfo.swift
//  OptimizeCollectionDemo
//
//  Created by apple on 2021/7/6.
//

import Foundation
import UIKit

///可以被显示的
public protocol Layoutable {
    associatedtype Content
    var frame: CGRect { get }
    var content: Content { get }
}

///竖直方向布局,计算高度
public protocol VerticalLayoutable:Layoutable {
    func performVerticalLayout(at point:CGPoint, for width:CGFloat)
}

///水平防线布局,计算高度
public protocol HorizontalLayoutable:Layoutable {
    func performHorizontolLayout(at point:CGPoint, for height:CGFloat)
}

//MARK: -

public class Layout<Info>: Layoutable {
    public var frame: CGRect
    
    public var content: Info
    
    init(frame: CGRect, content:Info) {
        self.content = content
        self.frame = frame
    }
}


public final class TextLayout:Layout<String> {
    
    public var font: UIFont
    public var color: UIColor
    
    init(frame: CGRect, content:String,font:UIFont = UIFont.systemFont(ofSize: 14.0) ,color:UIColor = .black) {
        self.font = font
        self.color = color
        super.init(frame: frame, content: content)
    }
}


//MARK: -

public protocol DisplayLayoutable {}

extension UIView: DisplayLayoutable {}

extension DisplayLayoutable where Self:UILabel  {
        
    func display<T>(layout:Layout<T>) {
        if let txt = layout.content as? String {
            self.text = txt
        }
        else if let attrTxt = layout.content as? NSAttributedString {
            self.attributedText = attrTxt
        }
        else if let nsStr = layout.content as? NSString {
            self.text = nsStr as String
        }
        else {
            self.text = nil
            self.attributedText = nil
        }
        self.frame = layout.frame
    }
}


extension DisplayLayoutable where Self: UITextField {
    func display<T>(layout:Layout<T>) {
        if let txt = layout.content as? String {
            self.text = txt
        }
        else if let attrTxt = layout.content as? NSAttributedString {
            self.attributedText = attrTxt
        }
        else if let nsStr = layout.content as? NSString {
            self.text = nsStr as String
        }
        else {
            self.text = nil
            self.attributedText = nil
        }
        self.frame = layout.frame
    }
    
    func displayPlaceHolder<T>(layout:Layout<T>) {
        if let txt = layout.content as? String {
            self.placeholder = txt
        }
        else if let attrTxt = layout.content as? NSAttributedString {
            self.attributedPlaceholder = attrTxt
        }
        else if let nsStr = layout.content as? NSString {
            self.placeholder = nsStr as String
        }
        else {
            self.placeholder = nil
            self.attributedText = nil
        }
        self.frame = layout.frame
    }
    
}

extension DisplayLayoutable where Self:UIImageView {
    
    func display<T>(layout:Layout<T>) {
        if let url = layout.content as? URL {
            if let data = try? Data(contentsOf: url) {
                self.image = UIImage(data: data)
            } else {
                self.image = nil
            }
        }
        else if let data = layout.content as? Data {
            self.image = UIImage(data: data)
        }
        else if let img = layout.content as? UIImage{
            self.image = img
        }
        else {
            self.image = nil
        }
        self.frame = layout.frame
    }
}


//MARK: -

class CellLayout: VerticalLayoutable {
    
    var frame: CGRect = .zero
    var content: Void = ()
    
    
    private(set) var iconL = Layout<UIImage?>.init(frame: .zero, content: nil)
    
    private(set) var nameL = Layout<NSAttributedString?>.init(frame: .zero, content: nil )
    
    private(set) var picL = Layout<URL?>.init(frame: .zero, content: nil)
    
    private(set) var txtL = TextLayout.init(frame: .zero, content: "")
    
    func performVerticalLayout(at point: CGPoint, for width: CGFloat) {
        let startX = point.x
        let startY = point.y
        
        iconL.frame = .init(x: startX, y: startY, width: 80, height: 80)
        iconL.content = UIImage(named: "aaa")
        
        nameL.frame = .init(x: iconL.frame.maxX + 10, y: iconL.frame.minY, width:  width - iconL.frame.maxX - 20, height: 40)
        nameL.content = NSAttributedString.init(string: "昵称")
        
        picL.frame = .init(x: startX, y: iconL.frame.maxY + 10, width: width, height: width)
        picL.content = URL(string: "图片链接地址")
        
        frame = CGRect(x: point.x, y: point.y, width: width, height: picL.frame.maxY - iconL.frame.minY + 10)
    }
    
    
}

class TestCell: UITableViewCell {
    let icon = UIImageView()
    let name = UILabel()
    let pic = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(icon)
        contentView.addSubview(name)
        contentView.addSubview(pic)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension DisplayLayoutable where Self:TestCell {
    func display(layout:CellLayout) {
        icon.display(layout: layout.iconL)
        name.display(layout: layout.nameL)
        pic.display(layout: layout.picL)
    }
}
