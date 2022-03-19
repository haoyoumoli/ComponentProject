//
//  CustomView.swift
//  LayoutDemo2
//
//  Created by apple on 2021/8/10.
//

import Foundation
import UIKit

class CustomView: UIView {
    let img = UIImageView()
    let lbl = UILabel()
    
    var imgHeightCon:NSLayoutConstraint? = nil
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [img,lbl].forEach({
            $0.translatesAutoresizingMaskIntoConstraints  = false
            self.addSubview($0)
        })
        
        img.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0.0).isActive = true
        img.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0.0).isActive = true
        img.topAnchor.constraint(equalTo:self.topAnchor, constant: 0.0).isActive = true
        
       // addImageHeightConstraints(multiplier: 0.0)
        
        
        lbl.font = UIFont.systemFont(ofSize: 15.0)
        lbl.textColor = .black
        lbl.numberOfLines = 0
        
        lbl.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0.0).isActive = true
        lbl.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0.0).isActive = true
        lbl.topAnchor.constraint(equalTo:img.bottomAnchor, constant: 0.0).isActive = true
        lbl.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateImageConstraints() {
        if let img  = self.img.image,img.size.width > 0 {
            addImageHeightConstraints(multiplier: img.size.height / img.size.width)
        }
    }
    
    
    func addImageHeightConstraints(multiplier:CGFloat) {
        imgHeightCon?.isActive = false
        let imgHeightCon = img.heightAnchor.constraint(equalTo: img.widthAnchor, multiplier: multiplier)
        imgHeightCon.isActive = true
        self.imgHeightCon = imgHeightCon
    }
    
    override func updateConstraints() {
        updateImageConstraints()
        super.updateConstraints()
    }
}
