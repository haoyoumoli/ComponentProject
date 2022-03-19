//
//  ViewController.swift
//  LayoutDemo2
//
//  Created by apple on 2021/8/9.
//

import UIKit

class ViewController: UIViewController {

    let customView = CustomView(frame: .zero)
    let imageV = UIImageView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //demo1()
       // demo2()
       // demo3()
        
       
    }
    
    func demo3() {
        imageV.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageV)
        
        imageV.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        imageV.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
        UIImage.loadImage("https://img1.ali213.net/glpic/2020/09/08/584_2020090835824689.gif") { image in
            self.imageV.image = image
        }
        
    }
    
    func demo2() {
        customView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customView)
        
        
        customView.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 20.0).isActive = true
        customView.topAnchor.constraint(equalTo: view.topAnchor,constant: 50.0).isActive = true
//        customView.widthAnchor.constraint(equalToConstant: 100.0)
//            .isActive = true
        customView.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -100.0).isActive = true
        
        customView.lbl.text = "张三的罪恶令我大开眼界，毕竟是个守法公民，我想象不到人世间有那么多罪恶，原本只晓得他贪污了女同事的韭黄，化身齐秦想要带人飞翔。非法制毒什么的我是想都不敢想的。罗云社视频浩如烟海，作为一个学法律的小学生，我能接触到的不过是沧海一粟。"

        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.customView.img.image = UIImage(named: "no-result")
            self.customView.updateImageConstraints()
            //self.customView.setNeedsUpdateConstraints()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let result = self.customView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                debugPrint(result,self.customView.frame)
            }
        }
    }
    
    func demo1() {
        let v = PersonInfoView(frame: .zero)
        
        view.addSubview(v)
        
        
        let vl = PersonInfoLayout(name: "张三", icon: UIImage(named: "no-result"), detail: "熟悉我的朋友都知道，我会迷恋世上一切奇怪的东西（不触犯法律与道德底线的前提下），最近就迷上了神似张学友的罗翔老师讲刑法，痴迷于法外狂徒张三的一系列离奇经历，张三的罪恶令我大开眼界，毕竟是个守法公民，我想象不到人世间有那么多罪恶，原本只晓得他贪污了女同事的韭黄，化身齐秦想要带人飞翔。非法制毒什么的我是想都不敢想的。罗云社视频浩如烟海，作为一个学法律的小学生，我能接触到的不过是沧海一粟。为快速了解张三其人，我上知乎查找了张三的罪行，然而张三的罪行似乎罄竹难书，居然没有好事者做出完整的总结。张三一如司法界的匈人，带来一片混乱，却不知他何时出现，也不知他何时消失。")

        
        v.frame = vl.layoutForWidth(view.bounds.width)
            .getFrame()
        v.displayLayout(vl)
        
        
        v.frame = v.frame.offsetBy(dx: 0, dy: 80.0)
        debugPrint(v.frame)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
      
    }

}

