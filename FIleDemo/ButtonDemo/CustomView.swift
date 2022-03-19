//
//  CustomView.swift
//  ButtonDemo
//
//  Created by apple on 2021/8/2.
//

import Foundation
import UIKit


class CustomButton: UIButton {
    let leftImg = UIImageView()
    let rightImg = UIImageView()
    let midTxt = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(leftImg)
        addSubview(rightImg)
        addSubview(midTxt)
        
        midTxt.textColor = .black
        midTxt.text = "are you ok?"
        
        leftImg.image = .image(with: .blue)
        rightImg.image = .image(with: .red)
        
        [midTxt,leftImg,rightImg].forEach {
            $0.isUserInteractionEnabled = false
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let h = self.bounds.height
        
        leftImg.frame = .init(x: 0, y: 0, width: h, height: h)
        rightImg.frame = .init(x: self.bounds.width - h, y: 0, width: h, height: h)
        midTxt.frame = .init(x: h, y: 0, width: self.bounds.width - h * 2, height: h)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
