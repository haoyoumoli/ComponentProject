//
//  PlayVideoViewController.swift
//  VideoPlayDemo
//
//  Created by apple on 2022/3/14.
//

import UIKit
import JPVideoPlayer
import SnapKit

class PlayVideoViewController:UIViewController {
    
    let videoPlayView:UIView = UIView()
    var inVideoURL: URL? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    deinit {
        videoPlayView.jp_stopPlay()
    }
}

extension PlayVideoViewController {
    func playVideo(url:URL) {
        videoPlayView.jp_playVideo(with: url, bufferingIndicator: JPVideoPlayerBufferingIndicator(), controlView: nil, progressView: nil, configuration: nil)
    }
       
}

fileprivate extension PlayVideoViewController {
    func setupUI() {
        view.backgroundColor = .red
        videoPlayView.backgroundColor = .black
        view.addSubview(videoPlayView)
        videoPlayView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom).offset(-40)
        }
    }
}
