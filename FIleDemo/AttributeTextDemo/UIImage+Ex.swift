//
//  UIImage+Ex.swift
//  AttributeTextDemo
//
//  Created by apple on 2021/10/14.
//

import UIKit

extension UIImage {
    
    func
    drawedInContainerFor
    (size:CGSize,
    imageRect:CGRect,
     backgroundColor:UIColor = .white)
    -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        defer { UIGraphicsEndImageContext() }
        guard
            let ctx = UIGraphicsGetCurrentContext()
        else { return self }
        ctx.setFillColor(backgroundColor.cgColor)
        ctx.fill(.init(x: 0, y: 0, width: size.width, height: size.height))
        self.draw(in: imageRect)
        guard let complexedImage = UIGraphicsGetImageFromCurrentImageContext() else  {
            return self
        }
        return complexedImage
    }
    
    
}

