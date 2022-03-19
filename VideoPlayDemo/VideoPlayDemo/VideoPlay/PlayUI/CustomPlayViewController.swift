//
//  CustomPlayViewController.swift
//  AVFoundationDemo
//
//  Created by apple on 2022/1/4.
//

import Foundation
import UIKit
import AVFoundation
import AVKit


extension AVPlayerItem {
    func debugPrintPropertyValues() {
        debugPrint("\(#keyPath(AVPlayerItem.canPlayReverse)): \(canPlayReverse)")
        debugPrint            ("\(#keyPath(AVPlayerItem.canPlayFastForward)): \(canPlayFastForward)")
        debugPrint("\(#keyPath(AVPlayerItem.canPlayFastReverse)) :\(canPlayFastReverse)")
        debugPrint("\(#keyPath(AVPlayerItem.canPlaySlowForward)) :\(canPlaySlowForward)")
        
        debugPrint("\(#keyPath(AVPlayerItem.canPlaySlowReverse)): \(canPlaySlowReverse)")
        debugPrint("\(#keyPath(AVPlayerItem.loadedTimeRanges)): \(loadedTimeRanges)")
        debugPrint("\(#keyPath(AVPlayerItem.seekableTimeRanges)): \(seekableTimeRanges)")
    }
}


//MARK: - Define
class CustomPlayViewController:UIViewController {
    var resourceLoadDelegate:AssetResourceLoaderDelegate? = nil
    
    lazy var resourceLoadQueue:DispatchQueue = {
        return DispatchQueue.init(label: "resource.loader.queue")
    }()
    
    
    var kvoManager = KVOManager()
    
}

//MARK: - SubTypes
extension CustomPlayViewController {
    
    struct VideoSchemes {
        static let delegate = "delegate:"
    }
    
    struct VideoUrls {
        static let runoob = URL.init(string: "http://www.runoob.com/try/demo_source/movie.mp4")!
        static let news = URL.init(string: "https://vd3.bdstatic.com/mda-na11q7w33jjrq8vt/sc/cae_h264_nowatermark/1641087804308675524/mda-na11q7w33jjrq8vt.mp4?v_from_s=hkapp-haokan-nanjing&auth_key=1641288475-0-0-3cb7d42861ff94e729ea4d0b3630b48a&bcevod_channel=searchbox_feed&pd=1&pt=3&logid=3475490681&vid=8731721874778387544&abtest=100254_2-17451_2-3000203_2&klogid=3475490681")!
        static let local = URL.init(fileURLWithPath: Bundle.main.path(forResource: "designedByAppleInCalifornia", ofType: "mp4")!)
        static let trailer = URL(string: "https://media.w3.org/2010/05/sintel/trailer.mp4")!
        static let mov_bbb = URL(string: "http://www.w3school.com.cn/example/html5/mov_bbb.mp4")!
    }
    
}

//MARK: - Override
extension CustomPlayViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        DispatchQueue.main.async { [self] in
            self.presentnVideoPlayerController()
           // self.setupCustomPlayerUI()
            //self.startDownloadVideo()
            //self.testWriteReadFile()
   
        }
        
    }
    
    struct RangesInfo {
        let cached:Bool
        let range:NSRange
        
        init(cached:Bool,range:NSRange) {
            self.cached = cached
            self.range = range
        }
    }
    
    
    func getRangesInfo3For(start:Int , end:Int) -> [RangesInfo] {
        guard start <= end else {
            return []
        }
        
        let cachedStringRanges = ["10-20","30-50","70-90"]
        
        let cachedRanges = cachedStringRanges.compactMap({
            return NSRange.createWith(beginEndFormatStr: $0)})
        
        var start = start
        var index = 0
        var result = [RangesInfo]()
        while start < end  && index < cachedRanges.count {
            defer { index += 1}
            let curRange = cachedRanges[index]
            
            let locationGreateStart = curRange.location >= start
            
            let startInCurRange = NSLocationInRange(start, curRange)
            
            if startInCurRange {
                result.append(.init(cached: true, range: NSMakeRange(start,NSMaxRange(curRange) - start)))
                start = NSMaxRange(curRange)
                
            } else if locationGreateStart {
                result.append(.init(cached: false, range: NSMakeRange(start, curRange.location - start)))
                start = curRange.location
                let maxRangeLessEnd = NSMaxRange(curRange) <= end
                let endInCurRange = NSLocationInRange(end, curRange)
                if endInCurRange {
                    result.append(.init(cached: true, range: NSMakeRange(curRange.location, end - curRange.location)))
                    start = end
                } else if maxRangeLessEnd {
                    result.append(.init(cached: true, range: curRange))
                    start = NSMaxRange(curRange)
                }
            }
        }
        
        //处理 end 比最大的range大的情况
        if  start < end,
            let lastRange = result.last?.range,
            NSMaxRange(lastRange) < end
        {
            result.append(.init(cached: false, range: NSMakeRange(NSMaxRange(lastRange), end - NSMaxRange(lastRange))))
        }
        
        return result
    }
}


//MARK: - Interface
extension CustomPlayViewController {
    
}

//MARK: - Private
private extension CustomPlayViewController {
    
    func testWriteReadFile() {
        let fileManager = FileManager.default
        
        let videoFile = VideoCacheFileManager.init(key: "test", path: "/Users/apple/Desktop")
        
        func testWrite() {
            let data = "x".data(using: .utf8)!
            do {
                try videoFile.write(data:data , offset: 15)
            } catch let err {
                debugPrint(err)
            }
        }
        
        func testRead() {
            do {
                if let data = try videoFile.read(offset: 0, length: 3) {
                    debugPrint(String(data: data, encoding: .utf8))
                }
            } catch let err {
                debugPrint(err)
            }
        }
        
        testRead()
        
        //cat -v 查看文件(可以显示空隙)
    }
    
    func startDownloadVideo() {
        let videoDownLoader = AssertDownloader.defaultDownloader
        
        videoDownLoader.didReceiveResponse = {
            (_ task: URLSessionTask, _ response: URLResponse) in
            debugPrint(response)
        }
        videoDownLoader.didComplete = {
            (_ task:AssertDownloader.TaskContext, _ error:Error?) in
            if error != nil {
                debugPrint(error!)
                return
            }
            guard
                var mimeType = task.response?.mimeType
            else {
                return
            }
            mimeType = mimeType.replacingOccurrences(of: "/", with: ".")
            let deskTopURL = URL(fileURLWithPath: "/Users/apple/Desktop/\(mimeType)")
            do {
                try task.data.write(to: deskTopURL)
            } catch let err {
                debugPrint(err)
            }
        }
        
        
        var request  = URLRequest.init(url: VideoUrls.runoob)
        request.httpMethod = "GET"
        _ = videoDownLoader.startDownload(for: request,resumeImmediately: true)
    }
    
    func setupCustomPlayerUI() {
     
        
        let playView = PlayerView()
        playView.backgroundColor = UIColor.black
        view.addSubview(playView)
        
        playView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playView.leftAnchor.constraint(equalTo: view.leftAnchor),
            playView.rightAnchor.constraint(equalTo: view.rightAnchor),
            playView.topAnchor.constraint(equalTo: view.topAnchor),
            playView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        playView.videoURL = VideoUrls.news
        
    }
    
    func presentnVideoPlayerController() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [])
        }
        catch {
            debugPrint("setting catogory to AVAudioSessionCategoryPlayback failed")
            return
        }
        
        let player = getAVPlayer(for: VideoUrls.news)
        let controller = AVPlayerViewController()
        controller.player = player
        present(controller, animated: true) {
            DispatchQueue.main.async {
                player?.play()
            }
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
