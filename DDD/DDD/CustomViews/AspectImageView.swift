//
//  AspectImageView.swift
//  DDD
//
//  Created by apple on 2022/7/21.
//

import UIKit


class AspectImageView:UIView {
    
    let imageView = UIImageView()
    
    private var imgSizeHeightCons:NSLayoutConstraint? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func setImage(_ img:UIImage?) {
        imageView.image = img
        _ = updateImgHeightConstraint()
    }
    
   
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        debugPrint("AspectImageView",#function,bounds,imageView.intrinsicContentSize)
//    }
    
    private func commonInit() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: self.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: self.rightAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    
    private func updateImgHeightConstraint() -> Bool {
        guard
            let imgSize = self.imageView.image?.size,
            imgSize.width > 0.0 else {
            return false
        }
        
        let ratio = imgSize.height / imgSize.width
        
        if self.imgSizeHeightCons == nil {
            self.imgSizeHeightCons = self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: ratio )
            self.imgSizeHeightCons?.isActive = true
            return true
        }
        
        let heightCons = self.imgSizeHeightCons!
        
        //差距很小就不更新约束了
        if abs(heightCons.multiplier - ratio) < 0.002 {
            return false
        }
        
        //更新约束
        self.removeConstraint(self.imgSizeHeightCons!)
        self.imgSizeHeightCons = self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: ratio )
        self.imgSizeHeightCons?.isActive = true
        return true
    }
    
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        let superSize = sizeThatFits(size)
//        debugPrint("AspectImageView",#function,superSize,size,bounds)
//        return superSize
//    }
//
//    override var intrinsicContentSize: CGSize {
//        let imageSize = imageView.intrinsicContentSize
//        return imageSize
//    }
}
