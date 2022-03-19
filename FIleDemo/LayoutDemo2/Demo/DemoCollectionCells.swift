//
//  DemoCell.swift
//  LayoutDemo2
//
//  Created by apple on 2021/8/11.
//

import Foundation
import UIKit

extension UICollectionViewCell {
    var collectionView:UICollectionView? {
        var viewPointer = self.superview
        while viewPointer != nil  {
            if let collectionV = viewPointer as? UICollectionView {
                return collectionV
            }
            viewPointer = viewPointer?.superview
        }
        return nil
    }
}

class DemoCollectionNormalCell: UICollectionViewCell {
    let lbl = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        lbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lbl)
        lbl.textAlignment = .center
        
        
        NSLayoutConstraint.activate([
            lbl.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0.0),
            lbl.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0.0),
            lbl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0),
            lbl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0.0),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
    //    debugPrint("DemoCollectionNormalCell:\(#function)")
        
        if let collectionV = self.collectionView,
           let flowLayout = collectionV.collectionViewLayout as? UICollectionViewFlowLayout {
           
            layoutAttributes.frame = CGRect(x: layoutAttributes.frame.minX, y: layoutAttributes.frame.minY, width:collectionV.frame.width - ( flowLayout.sectionInset.left + flowLayout.sectionInset.right) , height: 40.0)
        }
        
       
        return layoutAttributes
    }
}


class DemoCollectionCell: UICollectionViewCell {
    
    let customView = CustomView()
    
    var widthConstraits:NSLayoutConstraint? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(customView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0.0),
            customView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0.0),
            customView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0),
            customView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0.0),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
       // debugPrint("DemoCollectionCell:\(#function),\(layoutAttributes.indexPath)")
        
      
        if let collectionV = self.collectionView,
           let flowLayout = collectionV.collectionViewLayout as? UICollectionViewFlowLayout {
           
            
            let itemWidth = (collectionV.bounds.width - ( flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing )) * 0.5

            if self.widthConstraits == nil {
                widthConstraits = contentView.widthAnchor.constraint(equalToConstant: itemWidth)
                widthConstraits!.identifier = "temp-width"
                widthConstraits!.isActive = true
            } else {
                widthConstraits!.constant = itemWidth
            }
          
            
           let size = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
            
            layoutAttributes.frame = CGRect(x: layoutAttributes.frame.minX, y: layoutAttributes.frame.minY, width: size.width, height: size.height)
            
        }
        
    
        return layoutAttributes
    }
    
    
    
}
