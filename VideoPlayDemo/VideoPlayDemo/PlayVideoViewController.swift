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
        
        let progressView = JPVideoPlayerControlProgressView()
       
        let playControlView = JPVideoPlayerControlView.init(controlBar: nil, blurImage: nil)
        
        let controlBar = playControlView.controlBar as? JPVideoPlayerControlBar
        controlBar?.playButton.setImage(UIImage(named: "bofang.png"), for: .selected)
        videoPlayView.jp_videoPlayerDelegate = self
        videoPlayView.jp_playVideo(with: url,
                                   bufferingIndicator:JPVideoPlayerBufferingIndicator(), controlView: playControlView,
                                   progressView: nil,
                                   configuration:nil)
    }
    
        //JPVideoPlayerControlBar
        /*
         JPVideoPlayerControlView --> JPVideoPlayerControlBar
        */
       
}


extension PlayVideoViewController: JPVideoPlayerDelegate {
    func shouldAutoReplay(for videoURL: URL) -> Bool {
        return false
    }
}

fileprivate extension PlayVideoViewController {
    func setupUI() {
        view.backgroundColor = .black
        videoPlayView.backgroundColor = .black
        view.addSubview(videoPlayView)
        videoPlayView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom).offset(-40)
        }
    }
}
