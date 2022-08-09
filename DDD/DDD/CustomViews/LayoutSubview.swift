//
//  LayoutSubview.swift
//  DDD
//
//  Created by apple on 2022/7/20.
//

import UIKit

/// 统一的布局子View包装,方便添加布局参数,省去继承
class LayoutSubview: UIView {
    
    var margin = UIEdgeInsets.zero {
        didSet {
            superview?.setNeedsLayout()
        }
    }
    
    let child:UIView
    
    ///布局尺寸,支持自动计算或者手动指定
    ///如果指定为sizeFit, child要实现sizeThatFits方法
    enum LayoutSize:Equatable {
        case sizeFit
        case value(size:CGSize)
        case autoLayout
    }

    let layoutSize:LayoutSize
    
    required init(child:UIView,
                  margin:UIEdgeInsets = .zero,
                  layoutSize:LayoutSize = .sizeFit) {
        self.margin = margin
        self.child = child
        self.layoutSize = layoutSize
        super.init(frame: .zero)
        addSubview(child)
        if self.layoutSize == .autoLayout  {
            self.translatesAutoresizingMaskIntoConstraints = false
            self.child.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                child.leftAnchor.constraint(equalTo: self.leftAnchor),
                child.rightAnchor.constraint(equalTo: self.rightAnchor),
                child.topAnchor.constraint(equalTo: self.topAnchor),
                child.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ])
        }
    }
    
    required init?(coder: NSCoder) {
        self.child = UIView()
        self.layoutSize = .autoLayout
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switch self.layoutSize {
        case .sizeFit:
            child.frame = bounds
        case .value(size: _ ):
            child.frame = bounds
        case .autoLayout:
            break
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let childSize = child.sizeThatFits(size)
        return childSize
    }
    

}
