//
//  ViewController.swift
//  DDD
//
//  Created by apple on 2022/7/18.
//

import UIKit

class CutomLabel: UILabel {
    
    //    override var intrinsicContentSize: CGSize {
    //        let superSize = super.intrinsicContentSize
    //        debugPrint(#function,superSize)
    //        //label被限定100宽,但是其大小有200 会发生什么?
    //        //label最终只有100宽
    //        return superSize
    //    }
    //
    //    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
    //
    //        let result = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
    //        debugPrint(#function,bounds,result)
    //        return result
    //    }
    //
    //    open override func drawText(in rect: CGRect) {
    //        debugPrint(#function,rect)
    //        super.drawText(in: rect)
    //
    //    }
}

class RedView:UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = .red
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        demo3()
        //demo2()
    }
    
    
    func demo3() {
        
        func getLabelLayoutItem(_ text:String) -> HorizantolLayouter.LayoutItem {
            let lbl = UILabel()
            lbl.text = text
            lbl.textColor = UIColor.black
            lbl.layer.borderColor = UIColor.blue.cgColor
            lbl.layer.borderWidth = 1.0
            return HorizantolLayouter.LayoutItem.init(child: lbl, margin: .init(top: 0, left: 20.0, bottom: 10.0, right: 0.0))
        }
        
        func getCustomLayoutItem(_ text:String) -> HorizantolLayouter.LayoutItem {
            
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.layer.borderColor = UIColor.red.cgColor
            container.layer.borderWidth = 1.0
            
            let label = UILabel()
            label.text = text
            label.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)
            
            let rectView = UIView()
            rectView.backgroundColor = UIColor.darkGray
            rectView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(rectView)
            container.addSubview(label)
            container.addSubview(rectView)
            
            NSLayoutConstraint.activate([
                label.leftAnchor.constraint(equalTo: container.leftAnchor),
                label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                label.rightAnchor.constraint(equalTo: rectView.leftAnchor),
                rectView.widthAnchor.constraint(equalToConstant: 40.0),
                rectView.heightAnchor.constraint(equalToConstant: 40.0),
                rectView.rightAnchor.constraint(equalTo: container.rightAnchor),
                rectView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                rectView.topAnchor.constraint(equalTo: container.topAnchor),
            ])
            return .init(child: container, margin: .init(top: 0, left: 10, bottom: 30.0, right: 0), layoutSize: .autoLayout)
        }
        
        
        func getSizedViewLayoutIten(size:CGSize) -> HorizantolLayouter.LayoutItem {
            let redView = UIView()
            redView.backgroundColor = UIColor.red
            return HorizantolLayouter.LayoutItem.init(
                child:redView,
                margin: .init(top: 20, left: 50, bottom: 10, right: 10),
                layoutSize: .value(size:size))
        }
        
        let horizantolLayoutView = LayoutView()
        horizantolLayoutView.layouter = HorizantalItemAlignLayouter()
        let layouter =  horizantolLayoutView.layouter as! HorizantalItemAlignLayouter
        layouter.itemHorizantalAlign = .bottom
        layouter.addLayoutItem(getLabelLayoutItem("啊"))

        //添加指定大小的view
        layouter.addLayoutItem(getSizedViewLayoutIten(size: .init(width: 30, height: 60.0)))
        
//        //添加有自身大小的view
        layouter.addLayoutItem(getLabelLayoutItem("啊啊"))
        layouter.addLayoutItem(getLabelLayoutItem("啊啊啊"))
        layouter.addLayoutItem(getLabelLayoutItem("啊啊"))
        layouter.addLayoutItem(getLabelLayoutItem("啊"))
        layouter.addLayoutItem(getLabelLayoutItem("啊啊"))
        layouter.addLayoutItem(getSizedViewLayoutIten(size: .init(width: 30, height: 90.0)))
//
        ///添加使用自动布局确定大小的view
        layouter.addLayoutItem(getCustomLayoutItem("自动布局view"))
        layouter.addLayoutItem(getCustomLayoutItem("很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长"))

        layouter.addLayoutItem(getLabelLayoutItem("啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"))
        
      
        horizantolLayoutView.layer.borderColor = UIColor.black.cgColor
        horizantolLayoutView.layer.borderWidth = 1.0
        view.addSubview(horizantolLayoutView)
        
        horizantolLayoutView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            horizantolLayoutView.topAnchor.constraint(equalTo: view.topAnchor,constant: 50),
            horizantolLayoutView.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 20),
            horizantolLayoutView.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -20),
        ])
    }
    
    
    
    
    
    func demo1() {
        let redView = RedView()
        redView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = CutomLabel()
        label.text = "对照组"
        label.layer.borderColor = UIColor.red.cgColor
        label.layer.borderWidth = 1.0
        
        debugPrint(UIView.requiresConstraintBasedLayout)
        
        //        let stack = UIStackView()
        //        stack.axis = .horizontal
        //        stack.alignment = .center
        //        stack.addArrangedSubview(redView)
        //        stack.addArrangedSubview(label)
        //        label.translatesAutoresizingMaskIntoConstraints = false
        //        stack.translatesAutoresizingMaskIntoConstraints = false
        //        redView.translatesAutoresizingMaskIntoConstraints = false
        //        view.addSubview(stack)
        
        let agreementLbl = ActiveLabel()
        let t1: ActiveType = .custom(pattern: "《元集记平台转赠协议》")
        agreementLbl.enabledTypes.append(t1)
        agreementLbl.customize {
            [weak self] label in
            label.text = "勾选确认您已阅读《元集记平台转赠协议》"
            label.font = UIFont.systemFont(ofSize: 10.0)
            label.numberOfLines = 0
            label.textColor = UIColor.black
            label.customColor[t1] = UIColor.blue
            label.customSelectedColor[t1] = UIColor.blue
            label.fontFitWidth()
            
            label.handleCustomTap(for: t1) { x in
                
            }
        }
        agreementLbl.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.borderWidth = 1.0
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        containerView.addSubview(redView)
        containerView.addSubview(agreementLbl)
        
        NSLayoutConstraint.activate([
            redView.widthAnchor.constraint(equalToConstant: 50),
            redView.heightAnchor.constraint(equalToConstant: 50),
            redView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            redView.topAnchor.constraint(equalTo: containerView.topAnchor),
            redView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            agreementLbl.centerYAnchor.constraint(equalTo: redView.centerYAnchor),
            agreementLbl.leftAnchor.constraint(equalTo: redView.rightAnchor,constant: 10.0),
            agreementLbl.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //            stack.topAnchor.constraint(equalTo: view.topAnchor,constant: 50),
            //            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        
        ///BOOM!!!
        // stack.distribution = .fillProportionally
        // stack.addArrangedSubview(agreementLbl)
        
        // Do any additional setup after loading the view.
        let layoutContainerView = NoRenderView()
        layoutContainerView.backgroundColor = UIColor.red
        layoutContainerView.layer.borderColor = UIColor.black.cgColor
        layoutContainerView.layer.borderWidth = 5.0
        layoutContainerView.frame = .init(x: 50, y: 50, width: 150, height: 50)
        view.addSubview(layoutContainerView)
    }
}



extension UILabel {
    func fontFitWidth(minFontScaleFactor: CGFloat = 0.5) {
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = minFontScaleFactor
    }
    
}

extension UIColor {
    static var random:UIColor {
        
        return UIColor.init(red: CGFloat(arc4random() % 255)  / CGFloat(255.0), green:  CGFloat(arc4random() % 255)  / CGFloat(255.0), blue:  CGFloat(arc4random() % 255)  / CGFloat(255.0), alpha: 1.0)
    }
}
