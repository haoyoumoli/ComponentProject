//
//  IJKPlayViewController.swift
//  Live
//
//  Created by apple on 2022/4/13.
//

import UIKit
import IJKMediaFramework
class IJKPlayViewController: UIViewController {
    
    let url:URL
    
    init(with url:URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        remoVeMovieNotificationObservers()
    }
    
    private(set)
    var player:IJKFFMoviePlayerController? = nil
    
    private(set)
    var notiTokens:[NSObjectProtocol] = []
    
    let closeBtn = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFFPlayer()
        installMovieNotificationObservers()
        
        closeBtn.titleLabel?.font = .systemFont(ofSize: 25.0, weight: .bold)
        closeBtn.setTitleColor(.white, for: .normal)
        closeBtn.addTarget(self, action: #selector(closeBtnTouched(_:)), for: .touchUpInside)
        closeBtn.setTitle("X", for: .normal)
        view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 40.0, height: 40.0))
            make.right.equalToSuperview().offset(-20.0)
            make.top.equalToSuperview().offset(40.0)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.player?.view.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.player?.prepareToPlay()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.player?.shutdown()
    }
}

extension IJKPlayViewController {
    
}

fileprivate
extension IJKPlayViewController {
    func setupFFPlayer() {
#if DEBUG
        IJKFFMoviePlayerController.setLogReport(true)
        IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_DEBUG)
#else
        IJKFFMoviePlayerController.setLogReport(false)
        IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_INFO)
#endif
        IJKFFMoviePlayerController.checkIfFFmpegVersionMatch(true)
        
        self.player = IJKFFMoviePlayerController.init(contentURL: url, with: .byDefault())
        self.player!.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.player!.scalingMode = .aspectFit
        self.player!.shouldAutoplay = true
        view.addSubview(self.player!.view)
    }
    
    func installMovieNotificationObservers() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(loadStateDidChangeNoti(_:)), name: .IJKMPMoviePlayerLoadStateDidChange, object: player)
        center.addObserver(self, selector: #selector(moviePlayBackDidFinishNoti(_:)), name: .IJKMPMoviePlayerPlaybackDidFinish, object: player)
        center.addObserver(self, selector: #selector(mediaIsPreparedPlayDidChangeNoti(_:)), name: .IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: player)
        center.addObserver(self, selector: #selector(moviePlayBackStateDidChangeNoti(_:)), name: .IJKMPMoviePlayerPlaybackStateDidChange, object: player)
    }
    
    func remoVeMovieNotificationObservers() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: .IJKMPMoviePlayerLoadStateDidChange, object: player)
        center.removeObserver(self, name: .IJKMPMoviePlayerPlaybackDidFinish, object: player)
        center.removeObserver(self, name: .IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: player)
        center.removeObserver(self, name: .IJKMPMoviePlayerPlaybackStateDidChange, object: player)
    }
    
    ///加载状态变化
    @objc
    func loadStateDidChangeNoti(_ noti:Notification) {
        guard let loadState = player?.loadState else {
            return
        }
        if loadState.contains(.playthroughOK) {
            debugPrint("load state: playthroughOK ")
        } else if loadState.contains(.stalled) {
            debugPrint("load state: stalled ")
        } else {
            debugPrint("load state: unknown")
        }
    }
    
    ///播放结束原因
    @objc
    func moviePlayBackDidFinishNoti(_ noti:Notification) {
        
        guard
            let reasonValue = noti.userInfo?[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as? Int,
            let reason = IJKMPMovieFinishReason.init(rawValue: reasonValue)
        else {
            return
        }
        switch reason {
        case .playbackEnded:
            debugPrint("movie play back reason: ended")
        case .playbackError:
            debugPrint("movie play back reason: error")
        case .userExited:
            debugPrint("movie play back reason: user exited")
        @unknown default:
            debugPrint("movie play back reason: unknown")
        }
    }
    
    
    ///准备开始播放
    @objc
    func mediaIsPreparedPlayDidChangeNoti(_ noti:Notification) {
        debugPrint("mediaIsPreparedPlayDidChangeNoti")
    }
    
    ///回放状态改变
    @objc
    func moviePlayBackStateDidChangeNoti(_ noti:Notification) {
        guard
            let playbackState = player?.playbackState else {
                return
            }
        switch playbackState {
        case .stopped:
            debugPrint("movie play back state: stopped")
        case .playing:
            debugPrint("movie play back state: playing")
        case .paused:
            debugPrint("movie play back state: paused")
            
        case .interrupted:
            debugPrint("movie play back state: interrupted")
        case .seekingForward:
            debugPrint("movie play back state: seekingForward")
        case .seekingBackward:
            debugPrint("movie play back state: seekingBackward")
        @unknown default:
            debugPrint("movie play back state: unknown")
        }
    }
    
    
    @objc
    func closeBtnTouched(_ sender:UIButton) {
        if self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}


