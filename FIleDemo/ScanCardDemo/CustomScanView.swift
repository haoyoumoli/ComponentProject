//
//  CustomScanView.swift
//  ScanCardDemo
//
//  Created by apple on 2021/11/17.
//

import UIKit

class CustomScanView:UIView {
    
    let borderView = UIView()
    private var frameOfGuide:CGRect = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        borderView.layer.borderWidth = 1.0
        borderView.layer.borderColor = UIColor.yellow.cgColor
        addSubview(borderView)
    }
    
    override func layoutSubviews() {
        borderView.frame = bounds.insetBy(dx: 40.0, dy: 40.0)
        frameOfGuide = borderView.frame
    }
}


extension CustomScanView: EXOCRCustomScanViewDelegate {
    func getGuideRect(_ orientation: UIInterfaceOrientation) -> CGRect {
        debugPrint("getGuideRect",frameOfGuide)
        return frameOfGuide
    }
    
    func refreshScanView(_ orientation: UIInterfaceOrientation) {
        
    }
    
    func recoCompleted(_ info: Any!) {
        guard let idCardInfo = info as? EXOCRIDCardInfo else {
            return
        }
        debugPrint("recoCompleted",idCardInfo.toString() ?? "空")
    }
    
    
}
