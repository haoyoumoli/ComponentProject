

import UIKit

///一个布局容器, 水平排列子View,自动换行
///其所有的子view 必须是 LayoutItem
class LayoutView:UIView {

    var layouter:Layouter? {
        didSet {
            layouter?.layoutContainer = self
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layouter?.performLayout(for: bounds.size)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        layouter?.performLayout(for: size)
        return .init(width: size.width, height: layouter?.layoutedSize.height ?? 0.0)
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: bounds.width, height: layouter?.layoutedSize.height ?? 0.0)
    }
    
}

///布局尺寸,支持自动计算或者手动指定
///如果指定为sizeFit, child要实现sizeThatFits方法
enum SizeLayout:Equatable {
    case sizeFit
    case value(size:CGSize)
    case autoLayout
}

extension LayoutView {
    class Layouter {
        
        unowned fileprivate(set) var layoutContainer: UIView!
    
        var layoutedSize:CGSize { return .zero }
        ///将布局计算完成得到的尺寸值存入layoutedSize
        func performLayout(for size:CGSize) {}
    }
}


