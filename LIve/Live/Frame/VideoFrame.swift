//
//  VideoFrame.swift
//  Live
//
//  Created by apple on 2022/4/1.
//

import Foundation


class VideoFrame {
    var isKeyFrame:Bool
    var sps:Data
    var pps:Data
    var timestamp:UInt64
    var data: Data
    
    
    init(
        isKeyFrame:Bool,
        sps:Data,
        pps:Data,
        data:Data,
        timestamp:UInt64
    ) {
        self.isKeyFrame = isKeyFrame
        self.sps = sps
        self.pps = pps
        self.data = data
        self.timestamp = timestamp
    }
}
