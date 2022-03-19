//
//  ViewController.swift
//  CustomOperatorDemo
//
//  Created by apple on 2021/10/27.
//

import UIKit

struct TestStruct {
    var v1:String = ""
    var v2:Int = 0
}

class ViewController: UIViewController {
    
    ///系统写法比较冗长
    lazy private(set) var view1:UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.green
        return v
    }()
    
    //使用 .. 操作符,是不是好了点?
    lazy private(set) var
    view2 = UIView()..{
        $0.backgroundColor = UIColor.green
    }
    
    //连续调用
    let v1 = TestStruct()..{
        $0.v1 = "你好"
        $0.v2 = 10
    }..{
        $0.v1 = "第二次修改"
    }..{
        o in
        //blablabla...
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //看看v1的值,是所有block调用后结果的叠加
        debugPrint(v1)
        demo1()
        demo2()
    }
    
    
    ///使用..?操错符
    func demo1() {
        let result = TestStruct()..?{
            $0.v1 = "123132"
            $0.v2 = 321
            //返回true下面的闭包可以执行
            return true
        }..?{
            $0.v1 = "000"
            $0.v2 = 123
            //返回false下边的闭包不会被调动,并且最终的返回值变为nil
            return false
        }..?{
            $0.v1 = "不会被调用"
            return true
        }
        debugPrint(result == nil)
    }
    
    
    func demo2() {
        //级联操作符搭配返回可选值的函数
        func getValue(p:Bool) -> Int? {
            return p ? 10 : nil
        }
    
       let c = getValue(p: true)..?{
            //getValue的值不为空才会被执行
            debugPrint($0)
            return true
        }
        if c == nil {
            
        }
    }
    
}

