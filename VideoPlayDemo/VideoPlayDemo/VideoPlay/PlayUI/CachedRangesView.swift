//
//  CachedRangesView.swift
//  AVFoundationDemo
//
//  Created by apple on 2022/1/25.
//

import UIKit
//MARK: - Define
class CachedRangesView:UIView {
    
    var rangeColor:UIColor = UIColor.red
    
    weak var delegate:CachedRangesViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = UIColor.white
    }
    
    lazy private var ranges:[Range] = []
    lazy private var rangeItemViews:[UIView] = []
}

//MARK: - SubTypes
extension CachedRangesView {
    struct Range {
        //0.0~1.0
        let start:Double
        //0.0~1.0
        let end:Double
        
        init(start:Double,end:Double) {
            self.start = start
            self.end = end
        }
    }
}

//MARK: - Override
protocol CachedRangesViewDelegate:NSObjectProtocol {
    func cachedRangesView(view:CachedRangesView, rageItemAt index:Int,range:CachedRangesView.Range) -> UIView
}

extension CachedRangesView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutForRanges()
    }
}


//MARK: - Interface
extension CachedRangesView {
    func setRanges(_ ranges:[Range]) {
        self.ranges.removeAll()
        self.rangeItemViews.removeAll()
        self.ranges = ranges
        self.setNeedsLayout()
        
    }
}

//MARK: - Private
private extension CachedRangesView {
    func layoutForRanges() {
        var index = 0
        while index < ranges.count {
            defer { index += 1 }
            var itemV:UIView
            if let delegate = self.delegate {
                itemV = delegate.cachedRangesView(view: self, rageItemAt: index,range: ranges[index])
            } else {
                itemV = UIView()
                itemV.backgroundColor = self.rangeColor
                itemV.layer.cornerRadius = self.layer.cornerRadius
                itemV.clipsToBounds  = self.clipsToBounds
                itemV.layer.masksToBounds = self.layer.masksToBounds
                let xs = getStartAndEndX(for: ranges[index])
                itemV.frame = .init(x: xs.startX, y: 0, width: xs.endX - xs.startX, height: bounds.height)
            }
            self.addSubview(itemV)
            self.rangeItemViews.append(itemV)
        }
    }
    
    func getStartAndEndX(for range:Range) -> (startX:CGFloat,endX:CGFloat) {
        return ( range.start * bounds.width,range.end * bounds.width)
    }
}


