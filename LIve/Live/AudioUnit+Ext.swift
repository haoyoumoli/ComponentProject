//
//  AudioUnit+Ext.swift
//  Live
//
//  Created by apple on 2022/4/1.
//

import Foundation
import AudioUnit

extension AudioComponentDescription {
    static func getWith(componentType:OSType,componentSubType:OSType) -> AudioComponentDescription {
        var desc = AudioComponentDescription()
        desc.componentType = componentType
        desc.componentSubType = componentSubType
        desc.componentManufacturer = kAudioUnitManufacturer_Apple
        desc.componentFlags = 0
        desc.componentFlagsMask = 0
        return desc
    }
}
