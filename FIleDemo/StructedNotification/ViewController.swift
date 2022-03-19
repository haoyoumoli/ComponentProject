//
//  ViewController.swift
//  StructedNotification
//
//  Created by apple on 2021/7/22.
//

import UIKit

///唱歌通知
struct SingSong {
    let name:String
}


class ViewController: UIViewController {

    var notiTokenManager:NotificationTokenManager! = NotificationTokenManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        ///监听所有的唱歌通知
        Notification.SingSong.addObserver(object: nil, queue: .main) { (_ ,songName) in
            if let songName = songName {
                debugPrint("🎤 <<\(songName)>> ")
            }
        }.addTo(tokenManager: notiTokenManager)
        
        ///监听自己唱歌
        Notification.SingSong.addObserver(object: self, queue: .main) { object, songName in
            if let object = object,
               let songName = songName {
                debugPrint("\(object): 🎤 <<\(songName)>> ")
            }
        }.addTo(tokenManager: notiTokenManager)
        
        
        ///监听所有发送Post 的通知
        /// Post<String> 是 Post<Int> 是不同的通知
        Notification.Post<Int>.addObserver(object: nil, queue: .main) { _, value in
            debugPrint("接受到了Int值 :\(value)")
        }.addTo(tokenManager: notiTokenManager)
        
    }
    
    @IBAction func postSingSong(_ sender: Any) {
        
        Notification.SingSong.post(object: nil, value: "王妃")
    }
    
    @IBAction func postSelfSingSong(_ sender: Any) {
        Notification.SingSong.post(object: self, value: "青藏高原")
    }
    
    @IBAction func postInt(_ sender: Any) {
        
        Notification.Post<Int>.post(object: nil, value: 888)
        
        
        ///没有被监听
        Notification.Post<String>.post(object: nil, value: "555")
        
    }
    
    @IBAction func removeAllObserver(_ sender: Any) {
        
        
        debugPrint("移除了所有的监听token")
        self.notiTokenManager = nil
        
        // or
        //self.notiTokenManager.removeTokensForNotificationDefaultCenter()
    }
}

