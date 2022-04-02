//
//  AudioFrame.swift
//  Live
//
//  Created by apple on 2022/4/1.
//

import Foundation


class AudioFrame {
    
    let timeStamp:UInt64
    let data:Data
    let audioInfo:Data
    
    init(
        timeStamp:UInt64,
        data:Data,
        audioInfo:Data
    ) {
        self.timeStamp = timeStamp
        self.data = data
        self.audioInfo = audioInfo
    }
}
