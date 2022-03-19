//
//  UIimage+Network.swift
//  LayoutDemo2
//
//  Created by apple on 2021/8/11.
//

import Foundation
import UIKit

extension UIImage {
    
    ///简单的下载图片
    static func loadImage(_ urlStr:String,completion:@escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            guard let url = URL(string: urlStr) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            let data = try? Data.init(contentsOf: url)
            DispatchQueue.main.async {
                if data != nil {
                    completion(UIImage(data: data!))
                } else {
                    completion(nil)
                }
            }
        }
    }
}
