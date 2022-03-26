//
//  ViewController.swift
//  VideoPlayDemo
//
//  Created by apple on 2022/3/14.
//

import UIKit

import SnapKit

let news = URL.init(string: "https://vd3.bdstatic.com/mda-na11q7w33jjrq8vt/sc/cae_h264_nowatermark/1641087804308675524/mda-na11q7w33jjrq8vt.mp4?v_from_s=hkapp-haokan-nanjing&auth_key=1641288475-0-0-3cb7d42861ff94e729ea4d0b3630b48a&bcevod_channel=searchbox_feed&pd=1&pt=3&logid=3475490681&vid=8731721874778387544&abtest=100254_2-17451_2-3000203_2&klogid=3475490681")!

let localVideo = URL.init(fileURLWithPath: "/Users/apple/Downloads/168f91077823d1258f728ecbe4f7aa44.mp4")

class ViewController: UIViewController {
    
    let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
//        DispatchQueue.main.async {
//            let customPlay = CustomPlayViewController()
//            self.present(customPlay, animated: true, completion: nil)
//
////            let jpPlayController = PlayVideoViewController()
////            self.present(jpPlayController, animated: false, completion:  {
////                [weak jpPlayController] in
////                jpPlayController?.playVideo(url: news)
////
////            })
//
////            let isMp4 = "http://www.baidu.com/231324564.mp4".isMp4
////            debugPrint(isMp4)
//
//
//
//        }
        

        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        imageView.displayVideoFirstImage(url: news)
        
        
    }
    
    
}





