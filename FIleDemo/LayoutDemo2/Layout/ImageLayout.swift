//
//  ImageLayout.swift
//  LayoutDemo2
//
//  Created by apple on 2021/8/10.
//

import Foundation
import UIKit

//MARK: - UIImage
class ImageLayout: LayoutItem<UIImage> {

    override func layoutForWidth(_ width: CGFloat) -> Self {
        guard let d = getData(),d.size.width > 0 else {
           frame = .zero
            return self
        }
        frame = .init(x: 0,y: 0,width:width,
            height: width * d.size.height / d.size.width )
        return self
    }
    
}


//MARK: -
extension UIImageView {
    func displayLayout(_ layout:ImageLayout) {
        self.image = layout.getData()
        self.frame = layout.frame
    }
}
