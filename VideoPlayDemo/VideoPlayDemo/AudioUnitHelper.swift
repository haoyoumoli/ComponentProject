//
//  AudioUnitHelper.swift
//  VideoPlayDemo
//
//  Created by apple on 2022/3/26.
//

import Foundation
import AVFAudio
import AudioUnit

struct AudioUnitHelper {
    static
    func configAudioSession() {
        
        //获取音频会话
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            //设置以何种方式使用音频硬件做哪些处理
            try audioSession.setCategory(.playAndRecord)
            //设置I/O的buffer, buffer越小说明延时越低
            try audioSession.setPreferredIOBufferDuration(0.002)
            //设置采样频率,让硬件设备按照设置的采样频率来采集或者播放音频
            let hwSampleRate = 44100.0
            try audioSession.setPreferredSampleRate(hwSampleRate)
            //激活
            try audioSession.setActive(true, options: [])
            
        }catch let err {
            debugPrint(err)
        }
    }
    
    static
    //裸创建的方式
    func buildAudioUnit1() {
        
        var ioUnitDescription = AudioComponentDescription()
        ioUnitDescription.componentType = kAudioUnitType_Output
        ioUnitDescription.componentSubType = kAudioUnitSubType_RemoteIO
        ioUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple
        ioUnitDescription.componentFlags = 0
        ioUnitDescription.componentFlagsMask = 0
        
        guard let ioUnitRef:AudioComponent = AudioComponentFindNext(nil, &ioUnitDescription) else {
            return
        }
        //裸创建
        var ioUnitInstance:AudioUnit?
        AudioComponentInstanceNew(ioUnitRef, &ioUnitInstance)
    }
    
    static
    //使用AUGraph创建
    //作者说这样创建可以搭建出扩展性更高的系统
    func buildAudioUnit2() -> AudioUnit? {
        
        var ioUnitDescription = AudioComponentDescription()
        ioUnitDescription.componentType = kAudioUnitType_Output
        ioUnitDescription.componentSubType = kAudioUnitSubType_RemoteIO
        ioUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple
        ioUnitDescription.componentFlags = 0
        
        var processingGraph:AUGraph?
        NewAUGraph(&processingGraph)

        guard let processingGraph = processingGraph else {
            return nil
        }

        var ioNode: AUNode! = nil
        AUGraphAddNode(processingGraph, &ioUnitDescription, &ioNode)
        
        guard let ioNode = ioNode else {
            return nil
        }
        AUGraphOpen(processingGraph)
        
        var audioUnit:AudioUnit?
        AUGraphNodeInfo(processingGraph, ioNode, nil, &audioUnit)
        return audioUnit
    }
    
    
    
    static
    func usingLoudspeaker() {
        guard let remoteIOUnit = buildAudioUnit2() else {
            return
        }
        var status:OSStatus = noErr
        var oneFlag = 1
        let busZero:UInt32 = 0
        
        //启用扬声器
        status = AudioUnitSetProperty(remoteIOUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output,
                                      busZero,
                                      &oneFlag, UInt32(MemoryLayout.stride(ofValue: oneFlag)))
        if status != noErr {
            debugPrint("Could not Connect To Speaker")
        }
        
        //启用麦克风
        let busOne:UInt32 = 1
        AudioUnitSetProperty(remoteIOUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, busOne, &oneFlag, UInt32(MemoryLayout.stride(ofValue: oneFlag)))
        
        //Audio Stream描述
        let bytesPerSample = MemoryLayout<Float32>.stride
        var asbd = AudioStreamBasicDescription()
        //指定音频的编码格式
        asbd.mFormatID = kAudioFormatLinearPCM
       
/**       mFormatFlags是用来描述声音表示格式的参数，代码中的第一个参 数指定每个sample的表示格式是Float格式，这点类似于之前讲解的每个 sample都是使用两个字节(SInt16)来表示;然后是后面的参数 NonInterleaved，字面理解这个单词的意思是非交错的，其实对于音频 来讲就是左右声道是非交错存放的，实际的音频数据会存储在一个 AudioBufferList结构中的变量mBuffers中，如果mFormatFlags指定的是 NonInterleaved，那么左声道就会在mBuffers[0]里面，右声道就会在 mBuffers[1]里面;而如果mFormatFlags指定的是Interleaved的话，那么 左右声道就会交错排列在mBuffers[0]里面，理解这一点对于后续的开发 将是十分重要的。
 */
        asbd.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved
        asbd.mSampleRate = 44100.00
        asbd.mChannelsPerFrame = 2
        asbd.mFramesPerPacket = 1
        /**
         接下来的mBitsPerChannel表示的是一个声道的音频数据用多少位 来表示，前面已经提到过每个采样使用Float来表示，所以这里是使用8 乘以每个采样的字节数来赋值
         */
        asbd.mBitsPerChannel = UInt32(8 * bytesPerSample)
        /**
         最终是参数mBytesPerFrame和mBytesPerPacket的赋值，这里需要 根据mFormatFlags的值来进行分配，如果在NonInterleaved的情况下，就 赋值为bytesPerSample(因为左右声道是分开存放的);但如果是 Interleaved的话，那么就应该是bytesPerSample*channels(因为左右声道 是交错存放的)，这样才能表示一个Frame里面到底有多少个byte。
         */
        asbd.mBytesPerFrame = UInt32(bytesPerSample)
        asbd.mBytesPerPacket = UInt32(bytesPerSample)
        AudioUnitSetProperty(remoteIOUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &asbd, UInt32(MemoryLayout.stride(ofValue: asbd)))
    }
    
}


