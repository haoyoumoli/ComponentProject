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
        
        let json = #"{"title":"2131" }"#
        
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "YYYY-MM-dd HH:mm:ss"
        
        let date = Date()
        let timeInt = date.timeIntervalSince1970
        let str = dateFormate.string(from: date)
        let ti = dateFormate.date(from: str)!.timeIntervalSince1970
        debugPrint(timeInt,ti)
        //demo12()
       // demo11()
       // demo10()
       // demo9()
       // demo8()
       // demo7()
       // demo6()
       // demo4()
       // demo3()
        //demo2()
    }
    
    
    
    func demo12() {
        let hanlder = NSDecimalNumberHandler.init(roundingMode: .bankers, scale: 2, raiseOnExactness: true, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
        let max = NSDecimalNumber.maximum
        let result = try max.adding(NSDecimalNumber.one,withBehavior: hanlder)
       
       
        
    }

    func demo11() {
        ///开始时间倒计时
        func getCountDownBeginTimeStr() -> String {
          
            let nowTime = Date().timeIntervalSince1970
            let startTime:TimeInterval = nowTime + (60 * 60 * 24 * 365 * 3) + (60 * 60 * 24 * 30 * 3) + (60 * 60 * 24 * 2) + (3600 * 3) + (60 * 8) + 45
            let duration = Int(startTime - nowTime)
            return duration.dateDurationString(yearMark:"years ")
        }
        
        debugPrint(getCountDownBeginTimeStr())
    }
    
    
    func demo10() {
        let textV = YLTextView()
        textV.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textV)
        NSLayoutConstraint.activate([
            textV.leftAnchor.constraint(equalTo: view.leftAnchor),
            textV.rightAnchor.constraint(equalTo: view.rightAnchor),
            textV.topAnchor.constraint(equalTo: view.topAnchor, constant: 50.0),
            textV.heightAnchor.constraint(lessThanOrEqualToConstant: 70)
        ])
        textV.text = "《三国演义》（全名为《三国志通俗演义》，又称《三国志演义》）是元末明初小说家罗贯中根据陈寿《三国志》和裴松之注解以及民间三国故事传说经过艺术加工创作而成的长篇章回体历史演义小说，与《西游记》《水浒传》《红楼梦》并称为中国古典四大名著。该作品成书后有嘉靖壬午本等多个版本传于世，到了明末清初，毛宗岗对《三国演义》整顿回目、修正文辞、改换诗文，该版本也成为诸多版本中水平最高、流传最广的版本。《三国演义》可大致分为黄巾起义、董卓之乱、群雄逐鹿、三国鼎立、三国归晋五大部分，描写了从东汉末年到西晋初年之间近百年的历史风云，以描写战争为主，诉说了东汉末年的群雄割据混战和魏、蜀、吴三国之间的政治和军事斗争，最终司马炎一统三国，建立晋朝的故事。反映了三国时代各类社会斗争与矛盾的转化，并概括了这一时代的历史巨变，塑造了一群叱咤风云的三国英雄人物。《三国演义》是中国文学史上第一部章回小说，是历史演义小说的开山之作，也是第一部文人长篇小说，明清时期甚至有“第一才子书”之称。"
    }
    
    
    func demo9() {
        let decimalString = "9999999999999999999999999999999999999999999999999999999999999999999999999999999.99"
        debugPrint(decimalString.count)
        if let decimal = Decimal.init(string: decimalString) {
            ///可以创建成功,但是最大有效位数是38位
           debugPrint("\(decimal)")
        } else {
           debugPrint("创建失败")
        }
    }
    
    func demo8() {
        let aaa = PriceFormatter()
        aaa.formatText("¥5.12313")
        aaa.formatText("¥05.12313")
        aaa.formatText("0¥05.12313")
        aaa.formatText("¥7.5.12313")
      
    }
    
    func demo7() {
        let txt = YLTextField()
        txt.frame = .init(x: 20, y: 100, width: view.bounds.width - 40.0, height: 40.0)
        txt.layer.borderWidth = 1.0
        txt.layer.borderColor = UIColor.red.cgColor
        view.addSubview(txt)
    }
    
    func demo6() {
        /// NSTextLayout 系统计算文本高度,支持指定最大行数
        
        let paraStyle = NSMutableParagraphStyle()
        //paraStyle.lineHeightMultiple = 1.5
        paraStyle.minimumLineHeight = 50.0
        /// 万恶之源
        //paraStyle.lineBreakMode = .byTruncatingTail
        let attributeStr = NSAttributedString.init(string: "《三国演义》（全名为《三国志通俗演义》，又称《三国志演义》）是元末明初小说家罗贯中根据陈寿《三国志》和裴松之注解以及民间三国故事传说经过艺术加工创作而成的长篇章回体历史演义小说，与《西游记》《水浒传》《红楼梦》并称为中国古典四大名著。该作品成书后有嘉靖壬午本等多个版本传于世，到了明末清初，毛宗岗对《三国演义》整顿回目、修正文辞、改换诗文，该版本也成为诸多版本中水平最高、流传最广的版本。", attributes: [.font:UIFont.systemFont(ofSize: 20.0),
                                                                                                                                                                                                                                                                              .paragraphStyle:paraStyle
        ])
        
        
        let size = attributeStr.getSize(for: 300, maxLine: 3)
        //let size = attributeStr.getSize2(for: 300, maxLine: 0)
        //let size  = attributeStr.boundingRect(with: .init(width: 300, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).size
        debugPrint(size)
        
        let label = UILabel()
        label.numberOfLines = 0
        view.addSubview(label)
        label.attributedText = attributeStr
        ///必须重新设置截断模式,否则不起作用
        label.lineBreakMode = .byTruncatingTail
        label.frame = .init(x: 0, y: 100, width: size.width, height:size.height)
    }
    
    func demo5() {
        let txt = UITextField()
        txt.translatesAutoresizingMaskIntoConstraints = false
        txt.clearButtonMode = .always
        txt.backgroundColor = UIColor.lightGray
        do {
            let lbl = UILabel()
            lbl.text = "1213"
            txt.rightView = lbl
            txt.rightViewMode = .always
        }
        
        view.addSubview(txt)
        NSLayoutConstraint.activate([
            txt.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 10.0   ),
            txt.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -10 ),
            txt.heightAnchor.constraint(equalToConstant: 50.0),
            txt.topAnchor.constraint(equalTo: view.topAnchor,constant: 120)
            
        ])
    }
    
    
    func demo4() {
        let img = AspectImageView()
        let label = UILabel()
        
        view.addSubview(img)
        view.addSubview(label)
        
        label.text = "看看UIImageView在有图片后的约束变化"
        img.contentMode = .scaleAspectFit
        img.setImage(UIImage(named: "girl2"))
        
        img.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            img.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            img.centerYAnchor.constraint(equalTo: view.centerYAnchor),
          //  img.widthAnchor.constraint(equalToConstant: 300),
            img.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 1.0,constant: -40.0),
//            img.widthAnchor.constraint(equalTo: view.widthAnchor),
//            img.heightAnchor.constraint(equalToConstant: 100),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: img.bottomAnchor,constant: 10.0),
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            img.setImage(UIImage(named: "circle"))
        }
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
        let layouter = HorizantalItemAlignLayouter()
        horizantolLayoutView.layouter = layouter
     
        layouter.itemHorizantalAlign = .center
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


extension Int{
   
    
    func dateDurationString(
        yearMark:String = "年",
        monthMark:String = "月",
        dayMark:String = "日",
        hourMark:String = "小时",
        minutMark:String = "分",
        secondsMark:String = "秒"
    ) -> String {
        var duration = self
        guard duration > 0 else  {
            return ""
        }
        var result = ""
        let year = duration / (60 * 60 * 24 * 365)
        if year > 0 {
            result.append("\(year)\(yearMark)")
        }
        duration = duration - year * (60 * 60 * 24 * 365)
        
        let month = duration / (60 * 60 * 24 * 30)
        if month > 0 {
            result.append("\(month)\(monthMark)")
        }
        duration = duration - month *  (60 * 60 * 24 * 30)
        
        let day  = duration / (60 * 60 * 24)
        if day > 0 {
            result.append("\(day)\(dayMark)")
        }
        duration = duration - day * (60 * 60 * 24)
        
        let hour = duration / (60 * 60)
        if hour > 0 {
            result.append( "\(hour)\(hourMark)")
        }
        duration = duration - hour * (60 * 60)
        
        let min = duration / (60)
        if min > 0 {
            result.append("\(min)\(minutMark)")
        }
        duration = duration - min * (60)
        
        if duration > 0 {
            result.append("\(duration)\(secondsMark)")
        }
        return result
    }
}
