//
//  LiveViewController.swift
//  Live
//
//  Created by apple on 2022/4/14.
//

import UIKit
import LFRtmp
class LiveViewController: UIViewController {
    
    let preview = UIView()
    let startOrStopBtn = UIButton(type: .system)
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRtmpService()
    }
}


//MARK:  - Interface
extension LiveViewController {
    
}

//MARK: - private

fileprivate
extension LiveViewController {
    //初始化UI
    func setupUI() {
        //layout
        [preview,startOrStopBtn]
            .forEach{ view.addSubview($0) }
        preview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        startOrStopBtn.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
        }
        //set property
        startOrStopBtn.setTitle("开始", for: .normal)
        startOrStopBtn.setTitle("结束", for: .selected)
        startOrStopBtn.addTarget(self, action: #selector(startOrStopButtonTouched(_:)), for: .touchUpInside)
    }
    
    //初始化推流服务
    func setupRtmpService() {
        
    }
    
    @objc
    func startOrStopButtonTouched(_ sender:UIButton) {
        let bundle = Bundle.init(for: LFRtmp.ViewController.self)
        let vc = LFRtmp.ViewController.init(nibName: "ViewController", bundle: bundle)
        self.present(vc, animated: true, completion: nil)
    }
}


