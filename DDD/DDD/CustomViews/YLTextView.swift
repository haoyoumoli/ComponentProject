//
//  YLTextView.swift
//  DDD
//
//  Created by apple on 2022/8/4.
//

import Foundation
import UIKit

///有自身大小的TextViewYL
class YLTextView: UITextView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        textContainer.size = .init(width:bounds.width, height: .greatestFiniteMagnitude)
        let rect = layoutManager.usedRect(for: textContainer)
        return .init(width: bounds.width, height: rect.height + textContainer.lineFragmentPadding * 2 )
    }
}
