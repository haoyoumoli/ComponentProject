//
//  PlayView.swift
//  AVFoundationDemo
//
//  Created by apple on 2022/1/4.
//

import Foundation
import UIKit
import AVFoundation

//MARK: - Define
class PlayerView:UIView {
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    lazy private(set) var player:AVPlayer? = nil
    
    let playControlV = PlayControlView()
    let cachedRangesView = CachedRangesView()
    
    var videoURL:URL? {
        didSet {
            if oldValue != videoURL , videoURL != nil {
               videoURLIsChanged = true
            }
        }
    }
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    
    func commonInit() {
        playControlV.setPlayable(true)
        playControlV.delegate = self
        addSubview(playControlV)
        addSubview(cachedRangesView)
        
        cachedRangeObserver = NotificationCenter.default.addObserver(forName: AssetResourceLoaderDelegate.cachedRangeChanged, object: nil, queue: .main, using: { [weak self] noti  in
            
            guard
                let c = self,
                let delegate = noti.object as?AssetResourceLoaderDelegate,
                    let fullLength = delegate.videoFileManager.getFileFullLength()
            else {
                return
            }
            
            let cachedRanges = delegate.videoFileManager.getRangesInfo3For(start: 0, end: Int(fullLength))
                .filter({ $0.cached == true })
                .map({
                    return CachedRangesView.Range.init(start: Double($0.range.location) / Double(fullLength), end: Double(NSMaxRange($0.range)) / Double(fullLength))
                })
            c.cachedRangesView.setRanges(cachedRanges)
        })
    }
    
    deinit {
        removeObserverForPlayer()
        
        NotificationCenter.default.removeObserver(cachedRangeObserver as Any)
        
    }
    
    
    fileprivate var playerLayer:AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    private
    var kvoManager = KVOManager()
    
    lazy private
    var didPlayEndObserver:NSObjectProtocol? = nil
    
    lazy private
    var playerTimeObserver:Any? = nil
    
    lazy private
    var draggingProgressSlider = false
    
    lazy private
    var cachedRangeObserver:NSObjectProtocol? = nil
    
    var resourceLoadDelegate:AssetResourceLoaderDelegate? = nil
    
    lazy var resourceLoadQueue:DispatchQueue = {
        return DispatchQueue.init(label: "resource.loader.queue")
    }()
    
    
    lazy private
    var playerItem:AVPlayerItem? = nil
    
    lazy private
    var videoURLIsChanged:Bool = false
}

//MARK: - SubTypes
extension PlayerView {}

//MARK: - Override
extension PlayerView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        playControlV.frame = .init(x: 20, y: bounds.height - 100 - 20, width: bounds.width - 20 * 2, height: 100)
        
        cachedRangesView.frame = .init(x: playControlV.frame.minX, y: playControlV.frame.minY - 2.0, width: playControlV.frame.width, height: 10.0)
     
    }
}

//MARK: PlayControlViewDelegate
extension PlayerView:PlayControlViewDelegate {
    
    func didStartDragSlider(view: PlayControlView) {
        draggingProgressSlider = true
    }
    
    func playControlView(view: PlayControlView, dragingSlider value: Float) {
        
    }
    
    func playControlView(view: PlayControlView, silderDragEnd current: Float, max: Float) {
       
        guard
            let player = self.player,
            let item = player.currentItem
        else  { return }
        let total = item.duration
        player.pause()
        let toTime = CMTime.init(seconds: total.seconds * Double(current), preferredTimescale:  player.currentTime().timescale)
        
        //使用这个可以避免进度调整时的抖动
        player.seek(to: toTime, toleranceBefore: .zero, toleranceAfter: .zero) {  [weak player,weak self] finished  in
            
            if finished {
                self?.draggingProgressSlider = false
                player?.play()
            }
        }
    }
    
    func didPlay(view: PlayControlView) {
        if videoURLIsChanged {
            removeObserverForPlayer()
            player = getAVPlayer(for: videoURL!)
            listenStatusForNewPlayer()
            playerLayer.player = player
            videoURLIsChanged = false
            return
        }
        player?.play()
    }
    
    func didPause(view: PlayControlView) {
        player?.pause()
    }
}

//MARK: - Interface
extension PlayerView {
    
    
}


//MARK: - Private
private extension PlayerView {
    
    func removeObserverForPlayer() {
        //移除之前为player监听的通知
        kvoManager.unobserveAll()
        
        if let tk = self.didPlayEndObserver {
            NotificationCenter.default.removeObserver(tk)
        }
        
        if let tob = self.playerTimeObserver {
            player?.removeTimeObserver(tob)
        }
    }
    
    func listenStatusForNewPlayer() {
      
        guard
            let player = self.player,
            let playerItem = player.currentItem
        else { return }
        
        kvoManager.observe(for: playerItem, of: #keyPath(AVPlayerItem.status), options: [.old,.new], context: nil) { [weak self ] _, change in
            guard let c = self else { return }
            if
                let statusNumber = change?[.newKey] as? NSNumber,
                let status = AVPlayerItem.Status.init(rawValue: statusNumber.intValue)
            {
                if status == .readyToPlay {
                    if c.playControlV.state == .playing {
                        c.player?.play()
                    }
                } else {
                    debugPrint("视频不能播放")
                }
            
                
            }
        }
        
        playerTimeObserver = player.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 10), queue: nil) { [weak self] curr  in
            let total = playerItem.duration
            if self?.draggingProgressSlider == false {
                self?.playControlV.setProgress( Float(curr.seconds / total.seconds) )
            }
        }
        
        didPlayEndObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: nil) {  [weak self] noti  in
            self?.player?.seek(to: CMTime.init(value: 0, timescale: CMTimeScale(NSEC_PER_SEC)))
            self?.playControlV.changeToPauseUI()
        }
        
    }
    
    
    func getAVPlayer(for url:URL) -> AVPlayer? {
        self.resourceLoadDelegate = AssetResourceLoaderDelegate
            .init(asserURL: url, videoDownLoader: AssertDownloader.defaultDownloader)
        let avasset = AVURLAsset.init(url: self.resourceLoadDelegate!.handledUrl)
        avasset.resourceLoader.setDelegate(self.resourceLoadDelegate, queue: self.resourceLoadQueue)
        
        let playItem = AVPlayerItem.init(asset: avasset)
        
        let player = AVPlayer(playerItem: playItem)
        
        //设置了资源加载代理时,要将这个属性设为false
        player.automaticallyWaitsToMinimizeStalling = false
       
        return player
    }
    
}
