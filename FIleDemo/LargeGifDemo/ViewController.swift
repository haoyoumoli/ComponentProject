//
//  ViewController.swift
//  LargeGifDemo
//
//  Created by apple on 2022/6/8.
//

import UIKit
import SDWebImage
import SnapKit


struct ValueS:Cloneable {
   
    var string:String
    var int:Int
    
    var obj:Obj?
    
    init(string:String,int:Int,obj:Obj?) {
        self.string = string
        self.int = int
        self.obj = obj
    }
    
    func clone() -> ValueS {
        return ValueS(string: string, int: int, obj: obj?.clone())
    }
}


protocol Cloneable {
    func clone() -> Self
}

class Obj: Cloneable {
    
    func clone() -> Self {
        return Obj(string) as! Self
    }
    
    var string:String
    
    init(_ string:String) {
        self.string = string
    }
}



class ViewController: UIViewController {
   
    let imageV = UIImageView()
    let twoRectV = TwoRectView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTwoRectView()
        
    }
    
    func setupTwoRectView() {
        view.addSubview(twoRectV)
        twoRectV.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.width.equalTo(view)
            make.height.equalTo(view)
        }
    }

    
    func setupImageView() {
        view.addSubview(imageV)
        imageV.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.width.equalTo(view)
            make.height.equalTo(imageV.snp.width).multipliedBy(3.0 / 4.0)
        }
        
        //测试显示占用内存超大gif
        //gif的内存达到了80m
    }
    
    func demoCopyOnStructContainClass() {
        var str = "Hello, playground"

        let obj = Obj("你好")
        var vs = ValueS(string: "123456", int: 1, obj: obj)
        ///此时不会调用obj的set方法
        ///var vs2 = vs
        
        ///这里明确的复制
        var vs2 = vs.clone()
        vs2.string = "456"
        vs2.obj?.string = "你不的"
        ///并没有实现写时复制, obj没有被复制
        debugPrint(vs.obj?.string,vs2.obj?.string)
     
     
        let v = 2199 + 1099 + 209 * 2 + 159 + 379 + 299 + 369
        debugPrint(v)
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        return;
        
        super.touchesBegan(touches, with: event)
        
        let url = URL(fileURLWithPath: "/Users/apple/Desktop/large.gif")
        let url1 = URL(string: "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.jj20.com%2Fup%2Fallimg%2F1115%2F092221102018%2F210922102018-8-1200.jpg&refer=http%3A%2F%2Fimg.jj20.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1657331757&t=3ad77b0bb7ea4545fa3d90b5f9aae3f7")
        
        DispatchQueue.main.async { [self] in
            let imageVSize = imageV.frame.size
            let screenScale = UIScreen.main.scale
            
            debugPrint(CGSize(width: screenScale * imageVSize.width, height: screenScale * imageVSize.height))
            
            var context:[SDWebImageContextOption:Any] = [.imageThumbnailPixelSize:CGSize(width: screenScale * imageVSize.width, height: screenScale * imageVSize.height)]
            
            context[.imageTransformer] = self
            imageV.sd_setImage(with: url1, placeholderImage: nil, options: [], context: context, progress: nil) { image, err, cacheType, url in
                
                debugPrint(image,err,cacheType,url)
            }
            
            
        }
    }
}

extension ViewController:SDImageTransformer {
    var transformerKey: String {
        return "213456"
    }
    
    func transformedImage(with image: UIImage, forKey key: String) -> UIImage? {
        return image
    }
    
    
}
