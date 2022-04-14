//
//  IJKMoviePlayeDemoViewController.swift
//  Live
//
//  Created by apple on 2022/4/13.
//

import UIKit
import SnapKit


class IJKMoviePlayeDemoViewController: UIViewController {
    let textView = UITextView()
    let playButtn = UIButton(type: .system)
}

//MARK: Interface
extension IJKMoviePlayeDemoViewController {
    
}

//MARK: System
extension IJKMoviePlayeDemoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(textView)
        view.addSubview(playButtn)
        
        textView.font = .systemFont(ofSize: 18)
        textView.keyboardDismissMode = .onDrag
        textView.snp.makeConstraints { make in
            make.top.equalTo(     UIApplication.shared.statusBarFrame.height)
            make.left.right.equalToSuperview().inset(20.0)
            make.bottom.equalTo(playButtn.snp.top).offset(-20.0)
        }
        
        playButtn.setTitle("播放", for: .normal)
        playButtn.addTarget(self, action: #selector(playButtonTouched(_:)), for: .touchUpInside)
        playButtn.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(50.0)
        }
        
       
        //textView.text = "http://192.168.1.6:8080/localhost/live/livestream.flv"
        textView.text = "http://localhost:8080/localhost/live/livestream.flv"
    }
}

//MARK: private
fileprivate
extension IJKMoviePlayeDemoViewController {
    @objc
    func playButtonTouched(_ sender:UIButton) {
        
        guard let url = URL(string: textView.text) else {
            return
        }
        
        let ffplayervc = IJKPlayViewController.init(with: url)
        self.present(ffplayervc, animated: true, completion: nil)
    }
}
