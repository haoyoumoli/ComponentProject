//
//  HorizantalLayouter.swift
//  DDD
//
//  Created by apple on 2022/7/21.
//

import UIKit

///水平布局,自动换行,超出宽度按父容器以及margin左右设定宽度
class HorizantolLayouter:LayoutView.Layouter {
    
    fileprivate(set)
    var curX:CGFloat = 0.0
    
    fileprivate(set)
    var curY:CGFloat = 0.0
    
    fileprivate(set)
    var maxY:CGFloat = 0.0
    
    fileprivate(set)
    var layoutedWidth:CGFloat = 0.0
    
    override var layoutedSize: CGSize {
        return .init(width: layoutedWidth, height: maxY)
    }
    
    fileprivate(set) var layoutItems:[LayoutItem] = []
    
    func addLayoutItem(_ item:LayoutItem) {
        guard getIndex(for: item) == nil else {
            return
        }
        layoutItems.append(item)
        layoutContainer.addSubview(item.child)
    }
    
    func removeLayoutItem(_ item:LayoutItem) {
        guard let idx = getIndex(for: item) else {
            return
        }
        layoutItems.remove(at: idx)
        item.child.removeFromSuperview()
    }
    
    override func performLayout(for size:CGSize) {
        curX = 0
        curY = 0
        maxY = 0
        layoutedWidth = size.width
        layoutContainer.invalidateIntrinsicContentSize()
        for i in stride(from: 0, to: layoutContainer.subviews.count, by: 1) {
            
            let layoutItem = layoutItems[i]
            let subView = layoutItem.child
            var layoutSize:CGSize = .zero
            switch layoutItem.layoutSize {
            case .sizeFit:
                subView.sizeToFit()
                layoutSize = subView.bounds.size
            case .value(size: let s):
                layoutSize = s
            case .autoLayout:
                layoutSize = subView.bounds.size
            }
            performLayout(for: layoutItem,
                             itemSize: layoutSize,
                             containerSize: size)
        }
        
    }
    
    private func getIndex(for item:LayoutItem) -> Int? {
        return layoutItems.firstIndex(where: { $0.child == item.child})
    }
    
    fileprivate func  performLayout(for  layoutItem:LayoutItem,itemSize:CGSize,containerSize:CGSize) {
        var frame:CGRect = .zero
        
        if itemSize.width > containerSize.width {
            curY = maxY
            curX = 0
            if layoutItem.layoutSize == .autoLayout {
                ///这里可能令人困惑,没有设置frame, 但是在系统会触发布局好几次,
                ///在之后的布局流程中,会获取到使用自动布局撑开的view的准确大小
                ///并且能通过frame更改其坐标😂
                NSLayoutConstraint.activate([
                    layoutItem.child.leftAnchor.constraint(equalTo: self.layoutContainer.leftAnchor,constant: layoutItem.margin.left),
                    layoutItem.child.rightAnchor.constraint(equalTo: self.layoutContainer.rightAnchor,constant:  -layoutItem.margin.right),
                ])
            } else {
                frame = .init(x: layoutItem.margin.left + curX,
                              y: curY + layoutItem.margin.top,
                              width: containerSize.width - layoutItem.margin.left - layoutItem.margin.right,
                              height: itemSize.height)
            }
            
        } else {
            frame = .init(x:layoutItem.margin.left + curX,
                          y:curY + layoutItem.margin.top,
                          width: itemSize.width,
                          height: itemSize.height)
        }
        
        ///要换行
        if frame.maxX > containerSize.width {
            curX = 0
            curY = maxY
            frame = .init(x: layoutItem.margin.left + curX, y: curY + layoutItem.margin.top, width: itemSize.width, height: itemSize.height)
        }
        
        maxY = max(frame.maxY + layoutItem.margin.bottom, maxY)
        curX = frame.maxX
        
        debugPrint(frame)
        
        layoutItem.child.frame = frame
    }
}

extension HorizantolLayouter {
    class LayoutItem {
        
        let margin:UIEdgeInsets
        let child:UIView
        
        let layoutSize:SizeLayout
        
        init(child:UIView,
             margin:UIEdgeInsets = .zero,
             layoutSize:SizeLayout = .sizeFit) {
            self.margin = margin
            self.child = child
            self.layoutSize = layoutSize
        }
    }
}


//MARK: -
class HorizantalItemAlignLayouter:HorizantolLayouter {
    enum ItemHorizontalAlign {
        case top
        case bottom
        case center
    }
    var itemHorizantalAlign:ItemHorizontalAlign = .top
    var maxYChangeIdx:Int? = nil
    
    override func performLayout(for size: CGSize) {
        maxYChangeIdx = nil
        super.performLayout(for: size)
    }
    
    override func performLayout(for  layoutItem:LayoutItem,itemSize:CGSize,containerSize:CGSize) {
        switch itemHorizantalAlign {
        case .top:
            performLayoutAlignTop(for: layoutItem, itemSize: itemSize, containerSize: containerSize)
        case .bottom:
            performLayoutAlignBottom(for: layoutItem, itemSize: itemSize, containerSize: containerSize)
        case .center:
            performLayoutAlignCenter(for: layoutItem, itemSize: itemSize, containerSize: containerSize)
        }
    }
    
    ///先按最普通的方法会排列,在引起maxY改变的item发生时,fix修改其它item的坐标
    private func performLayoutAlignCenter(for  layoutItem:LayoutItem,itemSize:CGSize,containerSize:CGSize) {
        
        var frame:CGRect = .zero
     
        if itemSize.width > containerSize.width {
            //换行
            curY = maxY
            curX = 0
            if layoutItem.layoutSize == .autoLayout {
                ///这里可能令人困惑,没有设置frame, 但是在系统会触发布局好几次,
                ///在之后的布局流程中,会获取到使用自动布局撑开的view的准确大小
                ///并且能通过frame更改其坐标😂
                NSLayoutConstraint.activate([
                    layoutItem.child.leftAnchor.constraint(equalTo: self.layoutContainer.leftAnchor,constant: layoutItem.margin.left),
                    layoutItem.child.rightAnchor.constraint(equalTo: self.layoutContainer.rightAnchor,constant:  -layoutItem.margin.right),
                ])
            } else {
                frame = .init(x: layoutItem.margin.left + curX,
                              y: curY + layoutItem.margin.top,
                              width: containerSize.width - layoutItem.margin.left - layoutItem.margin.right,
                              height: itemSize.height)
                
            }
            
        } else {
            frame = .init(x:layoutItem.margin.left + curX,
                          y:curY + layoutItem.margin.top,
                          width: itemSize.width,
                          height: itemSize.height)
        }
        
        ///要换行
        if frame.maxX > containerSize.width {
            curX = 0
            curY = maxY
            frame = .init(x: layoutItem.margin.left + curX, y: curY + layoutItem.margin.top, width: itemSize.width, height: itemSize.height)
        }
        
        
        let newMaxY = frame.maxY + layoutItem.margin.bottom
        if  newMaxY > maxY {
            //maxY改变了,需要fix 之前的坐标
            if let fixStartIdx = layoutItems.firstIndex(where: { $0.child == layoutItem.child}),
               fixStartIdx != 0
            {
                debugPrint("fix start \(fixStartIdx) ,curX:\(curX),curY:\(curY),maxY:\(maxY),newMaxY:\(newMaxY)")
                let centerY = layoutItems[fixStartIdx].child.frame.midY
                for i in stride(from: maxYChangeIdx ?? 0, to: fixStartIdx, by: 1) {

                    let pre = layoutItems[i]
                    guard pre.child.frame.maxX <= layoutItems[fixStartIdx].child.frame.minX else {
                        continue
                    }

                    debugPrint("fix",i)
                    pre.child.frame = .init(x: pre.child.frame.minX, y: centerY - 0.5 * pre.child.bounds.height, width: pre.child.bounds.width, height: pre.child.bounds.height)

                }
               
                maxYChangeIdx = fixStartIdx
            }
            
            maxY = newMaxY
            debugPrint("-----")
        } else if maxYChangeIdx != nil {
            //当前item 并没有使当前maxY发生变化,则其必须与前一个引起maxY变化的item中心对齐
            frame = .init(x: layoutItem.margin.left + curX,
                          y: layoutItems[maxYChangeIdx!].child.frame.midY - itemSize.height * 0.5,
                          width:itemSize.width,
                          height: itemSize.height)
            
        }
        curX = frame.maxX
        
        layoutItem.child.frame = frame
        
        
    }
    
    private func performLayoutAlignBottom(for  layoutItem:LayoutItem,itemSize:CGSize,containerSize:CGSize) {
        
        var frame:CGRect = .zero
     
        if itemSize.width > containerSize.width {
            //换行
            curY = maxY
            curX = 0
            if layoutItem.layoutSize == .autoLayout {
                ///这里可能令人困惑,没有设置frame, 但是在系统会触发布局好几次,
                ///在之后的布局流程中,会获取到使用自动布局撑开的view的准确大小
                ///并且能通过frame更改其坐标😂
                NSLayoutConstraint.activate([
                    layoutItem.child.leftAnchor.constraint(equalTo: self.layoutContainer.leftAnchor,constant: layoutItem.margin.left),
                    layoutItem.child.rightAnchor.constraint(equalTo: self.layoutContainer.rightAnchor,constant:  -layoutItem.margin.right),
                ])
            } else {
                frame = .init(x: layoutItem.margin.left + curX,
                              y: curY + layoutItem.margin.top,
                              width: containerSize.width - layoutItem.margin.left - layoutItem.margin.right,
                              height: itemSize.height)
                
            }
            
        } else {
            frame = .init(x:layoutItem.margin.left + curX,
                          y:curY + layoutItem.margin.top,
                          width: itemSize.width,
                          height: itemSize.height)
        }
        
        ///要换行
        if frame.maxX > containerSize.width {
            curX = 0
            curY = maxY
            frame = .init(x: layoutItem.margin.left + curX, y: curY + layoutItem.margin.top, width: itemSize.width, height: itemSize.height)
        }
        
        
        let newMaxY = frame.maxY + layoutItem.margin.bottom
        if  newMaxY > maxY {
            //maxY改变了,需要fix 之前的坐标
            if let fixStartIdx = layoutItems.firstIndex(where: { $0.child == layoutItem.child}),
               fixStartIdx != 0
            {
                debugPrint("fix start \(fixStartIdx) ,curX:\(curX),curY:\(curY),maxY:\(maxY),newMaxY:\(newMaxY)")
                let bottomY = layoutItems[fixStartIdx].child.frame.maxY
                for i in stride(from: maxYChangeIdx ?? 0, to: fixStartIdx, by: 1) {

                    let pre = layoutItems[i]
                    guard pre.child.frame.maxX <= layoutItems[fixStartIdx].child.frame.minX else {
                        continue
                    }

                    debugPrint("fix",i)
                    pre.child.frame = .init(x: pre.child.frame.minX, y: bottomY -  pre.child.bounds.height, width: pre.child.bounds.width, height: pre.child.bounds.height)
                }
                maxYChangeIdx = fixStartIdx
            }
            
            maxY = newMaxY
            debugPrint("-----")
        } else if maxYChangeIdx != nil {
            //当前item 并没有使当前maxY发生变化,则其必须与前一个引起maxY变化的item中心对齐
            frame = .init(x: layoutItem.margin.left + curX,
                          y: layoutItems[maxYChangeIdx!].child.frame.maxY - itemSize.height,
                          width:itemSize.width,
                          height: itemSize.height)
            
        }
        curX = frame.maxX
        
        layoutItem.child.frame = frame
        
        
    }
    
    private func performLayoutAlignTop(for  layoutItem:LayoutItem,itemSize:CGSize,containerSize:CGSize) {
        
        var frame:CGRect = .zero
     
        if itemSize.width > containerSize.width {
            //换行
            curY = maxY
            curX = 0
            if layoutItem.layoutSize == .autoLayout {
                ///这里可能令人困惑,没有设置frame, 但是在系统会触发布局好几次,
                ///在之后的布局流程中,会获取到使用自动布局撑开的view的准确大小
                ///并且能通过frame更改其坐标😂
                NSLayoutConstraint.activate([
                    layoutItem.child.leftAnchor.constraint(equalTo: self.layoutContainer.leftAnchor,constant: layoutItem.margin.left),
                    layoutItem.child.rightAnchor.constraint(equalTo: self.layoutContainer.rightAnchor,constant:  -layoutItem.margin.right),
                ])
            } else {
                frame = .init(x: layoutItem.margin.left + curX,
                              y: curY + layoutItem.margin.top,
                              width: containerSize.width - layoutItem.margin.left - layoutItem.margin.right,
                              height: itemSize.height)
                
            }
            
        } else {
            frame = .init(x:layoutItem.margin.left + curX,
                          y:curY + layoutItem.margin.top,
                          width: itemSize.width,
                          height: itemSize.height)
        }
        
        ///要换行
        if frame.maxX > containerSize.width {
            curX = 0
            curY = maxY
            frame = .init(x: layoutItem.margin.left + curX, y: curY + layoutItem.margin.top, width: itemSize.width, height: itemSize.height)
        }
        
        
        let newMaxY = frame.maxY + layoutItem.margin.bottom
        if  newMaxY > maxY {
            //maxY改变了,需要fix 之前的坐标
            if let fixStartIdx = layoutItems.firstIndex(where: { $0.child == layoutItem.child}),
               fixStartIdx != 0
            {
                debugPrint("fix start \(fixStartIdx) ,curX:\(curX),curY:\(curY),maxY:\(maxY),newMaxY:\(newMaxY)")
                let topY = layoutItems[fixStartIdx].child.frame.minY
                for i in stride(from: maxYChangeIdx ?? 0, to: fixStartIdx, by: 1) {

                    let pre = layoutItems[i]
                    guard pre.child.frame.maxX <= layoutItems[fixStartIdx].child.frame.minX else {
                        continue
                    }

                    debugPrint("fix",i)
                    pre.child.frame = .init(x: pre.child.frame.minX, y: topY, width: pre.child.bounds.width, height: pre.child.bounds.height)

                }
               
                maxYChangeIdx = fixStartIdx
            }
            
            maxY = newMaxY
            debugPrint("-----")
        } else if maxYChangeIdx != nil {
            //当前item 并没有使当前maxY发生变化,则其必须与前一个引起maxY变化的item中心对齐
            frame = .init(x: layoutItem.margin.left + curX,
                          y: layoutItems[maxYChangeIdx!].child.frame.minY,
                          width:itemSize.width,
                          height: itemSize.height)
            
        }
        curX = frame.maxX
        
        layoutItem.child.frame = frame
        
        
    }
}
