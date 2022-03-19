//
//  ViewController.swift
//  FadeLabelDemo
//
//  Created by apple on 2022/1/4.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let lblFrame:CGRect = .init(x: 10, y: 120, width: 300, height: 50)
        let lblBounds:CGRect = .init(x: 0, y: 0, width: lblFrame.width, height: lblFrame.height)
        
        let lbl = UILabel()
        lbl.frame = lblFrame
        
        let paraStyle = NSMutableParagraphStyle.init()
        paraStyle.lineBreakStrategy = .pushOut
        //paraStyle.lineBreakMode = .byClipping
        lbl.attributedText =  NSAttributedString.init(string: "文本文本文本文本文本文本文本文本文本文本文本啊啊",attributes: [.paragraphStyle:paraStyle,.font:UIFont.systemFont(ofSize: 20.0, weight: .bold)])
        lbl.lineBreakMode = .byCharWrapping
        view.addSubview(lbl)
        
        let maskLayer = CAGradientLayer()
        maskLayer.colors = [
            UIColor.red.withAlphaComponent(1.0).cgColor,
            UIColor.red.withAlphaComponent(0.0).cgColor
        ]
        maskLayer.locations = [0.8,1.0]
        maskLayer.startPoint = .init(x: 0.0, y: 0.0)
        maskLayer.endPoint = .init(x: 1.0, y: 0.0)
        maskLayer.anchorPoint = .zero
        maskLayer.frame = lblBounds
        
        lbl.layer.mask = maskLayer
    
    }


}

