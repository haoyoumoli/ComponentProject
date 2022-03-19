//
//  LabelContainrView.swift
//  LabelLayoutDemo
//
//  Created by apple on 2022/2/22.
//

import UIKit

//MARK: - Define
class LabelContainerView:UIView {
    
    let lbl0 = UILabel()
    let lbl1 = UILabel()
    let columStack = UIStackView()
    
    lazy private var rowStacks = [UIStackView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
}

//MARK: - SubTypes
extension LabelContainerView {}

//MARK: - Override
extension LabelContainerView {
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}


//MARK: - Interface
extension LabelContainerView {
    func setData(txt0:String,txt1:String) {
        lbl0.text = txt0
        lbl1.text = txt1
        
        if self.bounds.width == 0 {
            self.layoutIfNeeded()
        }
        
        func caluateTxtSize(str:String,font:UIFont) -> CGSize {
            let attri = NSMutableAttributedString(string: str,attributes: [.font: font])
            let size = attri.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesFontLeading, context: nil).size
            return size
        }
        
        let txt0Size = caluateTxtSize(str: txt0, font: lbl0.font)
        let txt1Size = caluateTxtSize(str: txt1, font: lbl1.font)
        
        if txt0Size.width + txt1Size.width > self.bounds.width {
            //一行放不下
            rowStacks.first?.removeArrangedSubview(lbl1)
            let row = createRowStack()
            row.addArrangedSubview(lbl1)
            columStack.addArrangedSubview(row)
            rowStacks.append(row)
        } else {
            // 一行的方的下
            rowStacks.last?.removeArrangedSubview(lbl1)
            rowStacks.first?.addArrangedSubview(lbl1)
        }
    }
    
}

//MARK: - Private
private extension LabelContainerView {
    func commonInit() {
        columStack.axis = .vertical
        columStack.alignment = .center
        addSubview(columStack)
        columStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            columStack.leftAnchor.constraint(equalTo: self.leftAnchor),
            columStack.rightAnchor.constraint(equalTo: self.rightAnchor),
            columStack.topAnchor.constraint(equalTo: self.topAnchor),
            columStack.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        let row = createRowStack()
        row.addArrangedSubview(lbl0)
        row.addArrangedSubview(lbl1)
        
        rowStacks.append(row)
        columStack.addArrangedSubview(row)
    }
    
    func createRowStack() -> UIStackView {
        let stack = UIStackView()
        stack.alignment = .center
        stack.axis = .horizontal
        return stack
    }
}

