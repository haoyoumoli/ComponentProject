//
//  UIImage+Color.swift
//  ButtonDemo
//
//  Created by apple on 2021/8/2.
//

import Foundation
import UIKit

extension UIImage {
    
    static func image(with color:UIColor,
                      size:CGSize = .init(width: 1.0, height: 1.0) ) -> UIImage? {
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(color.cgColor)
        ctx?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        return img
        
    }
}
