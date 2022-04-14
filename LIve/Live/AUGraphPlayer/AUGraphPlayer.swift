//
//  AUGraphPlayer.swift
//  Live
//
//  Created by apple on 2022/4/2.
//

import Foundation
import AudioToolbox
import AVFAudio
import UserNotifications

class AUGraphPlayer {
    
    
    private(set)
    var playPath:URL
    
    init(filePath:String) throws {
        playPath = URL(fileURLWithPath: filePath)
        let session = ELAudioSession.shared
        try session.set(category: .playAndRecord)
        try session.set(preferredLatency: .default)
        try session.set(active: true)
        addAudioSessionInterruptedObserver()
        if initializePlayGraph() == false {
            debugPrint("设置AUGraph失败")
        }
    }
    
    deinit {
        removeAudioSessionInterruptedObserver()
    }
    
    private(set)
    var mPlayerGraph:AUGraph? = nil
    
    private(set)
    var mPlayerNode:AUNode = 0
    
    
    private(set)
    var mSplitterNode:AUNode = 0
    
    
    private(set)
    var mSplitterUnit:AudioUnit? = nil
    
    
    private(set)
    var mAccMixerNode:AUNode = 0
    
    
    private(set)
    var mAccMixerUnit:AudioUnit? = nil
    
    
    private(set)
    var mVocalMixerNode:AUNode = 0
    
    
    private(set)
    var mVocalMixerUnit:AudioUnit? = nil
    
    
    private(set)
    var mPlayerUnit: AudioUnit? = nil
    
    
    private(set)
    var mPlayerIONode: AUNode = 0
    
    
    private(set)
    var mPlayerIOUnit: AudioUnit? = nil
    
    
}


//MARK:- AUGrpahPlayer Interface
extension AUGraphPlayer {
    
    func initializePlayGraph() -> Bool {
        //1:构造AUGraph
        var status = NewAUGraph(&mPlayerGraph)
        guard
            check(status, "Could not creat a new AUGraph."),
            let mPlayerGraph = self.mPlayerGraph
        else { return false }
        
        //添加IONode
        var ioDesc = AudioComponentDescription()
        ioDesc.componentManufacturer = kAudioUnitManufacturer_Apple
        ioDesc.componentType = kAudioUnitType_Output
        ioDesc.componentSubType = kAudioUnitSubType_RemoteIO
        //        ioDesc.componentFlags = 0
        //        ioDesc.componentFlagsMask = 0
        status = AUGraphAddNode(mPlayerGraph, &ioDesc, &mPlayerIONode)
        guard
            check(status, "Could not add i/o node to graph.")
        else { return false }
        
        //添加playerNode
        var playerDesc = AudioComponentDescription()
        playerDesc.componentManufacturer = kAudioUnitManufacturer_Apple
        playerDesc.componentType = kAudioUnitType_Generator
        playerDesc.componentSubType = kAudioUnitSubType_AudioFilePlayer
        //        playerDesc.componentFlags = 0
        //        playerDesc.componentFlagsMask = 0
        status = AUGraphAddNode(mPlayerGraph, &playerDesc, &mPlayerNode)
        guard
            check(status, "Could not add file player node to graph")
        else { return false }
        
        //添加分离器
        var splitterDesc = AudioComponentDescription()
        splitterDesc.componentManufacturer = kAudioUnitManufacturer_Apple
        splitterDesc.componentType = kAudioUnitType_FormatConverter
        splitterDesc.componentSubType = kAudioUnitSubType_Splitter
        //        splitterDesc.componentFlags = 0
        //        splitterDesc.componentFlagsMask = 0
        status = AUGraphAddNode(mPlayerGraph, &splitterDesc, &mSplitterNode)
        guard
            check(status, "Could not add  node splitter to graph")
        else { return false }
        
        //添加Mixer
        var mixerDesc = AudioComponentDescription()
        mixerDesc.componentManufacturer = kAudioUnitManufacturer_Apple
        mixerDesc.componentType = kAudioUnitType_Mixer
        mixerDesc.componentSubType = kAudioUnitSubType_MultiChannelMixer
        //        mixerDesc.componentFlags = 0
        //        mixerDesc.componentFlagsMask = 0
        status = AUGraphAddNode(mPlayerGraph, &mixerDesc, &mVocalMixerNode)
        guard
            check(status ,"Could not add  mVocalMixerNode to graph") == true
        else { return false }
        status = AUGraphAddNode(mPlayerGraph, &mixerDesc, &mAccMixerNode)
        guard
            check(status,"Could not add  mAccMixerNode to graph")
        else{ return false }
        
        //打开graph,只有真正的打开了Graph才会实例化每一个Node
        guard
            check(AUGraphOpen(mPlayerGraph), "Could not open graph"),
            check(AUGraphNodeInfo(mPlayerGraph, mPlayerIONode, nil, &mPlayerIOUnit), "Could not retrieve node info for mPlayerIONode"),
            mPlayerIOUnit != nil,
            check(AUGraphNodeInfo(mPlayerGraph, mPlayerNode , nil, &mPlayerUnit), "Could not retrieve node info for mPlayerIONode"),
            mPlayerUnit != nil,
            check(AUGraphNodeInfo(mPlayerGraph, mSplitterNode , nil, &mSplitterUnit), "Could not retrieve node info for mSplitterNoder"),
            mSplitterUnit != nil,
            check(AUGraphNodeInfo(mPlayerGraph, mVocalMixerNode , nil, &mVocalMixerUnit), "Could not retrieve node info for mVocalMixerNode"),
            mVocalMixerUnit != nil,
            check(AUGraphNodeInfo(mPlayerGraph, mAccMixerNode , nil, &mAccMixerUnit), "Could not retrieve node info for mAccMixerNode"),
            mAccMixerUnit != nil
        else { return false }
        
        //给Audio Unit设置参数
        var stereoStreamFormat = AudioStreamBasicDescription()
        stereoStreamFormat.mFormatID = kAudioFormatLinearPCM
        stereoStreamFormat.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved
        let bytesPerSample = UInt32(MemoryLayout<Float32>.stride)
        stereoStreamFormat.mBytesPerPacket = bytesPerSample
        stereoStreamFormat.mFramesPerPacket = 1
        stereoStreamFormat.mBytesPerFrame = bytesPerSample
        stereoStreamFormat.mChannelsPerFrame = 2
        stereoStreamFormat.mBitsPerChannel = 8 * bytesPerSample
        stereoStreamFormat.mSampleRate = 48000.0
        stereoStreamFormat.mReserved = 0
        
        let formatSize = UInt32(MemoryLayout.stride(ofValue: stereoStreamFormat))
        debugPrint("size:\(formatSize) ")
        guard
            check(
                AudioUnitSetProperty(
                    mPlayerIOUnit!,
                    kAudioUnitProperty_StreamFormat,
                    kAudioUnitScope_Output,
                    1,
                    &stereoStreamFormat,
                    formatSize
                ),
                "Set remote IO output element stream format failed."),
            check(
                AudioUnitSetProperty(
                    mPlayerUnit!,
                    kAudioUnitProperty_StreamFormat,
                    kAudioUnitScope_Output,
                    0,
                    &stereoStreamFormat,
                    formatSize
                ),
                "Could not Set StreamFormat for Player Unit") else {
                    return false
                }
        
        //配置Splitter属性
        status = AudioUnitSetProperty(mSplitterUnit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &stereoStreamFormat, formatSize)
        guard check(status, "Could not Set StreamFormat output for Splitter Unit") else {
            return false
        }
        status = AudioUnitSetProperty(mSplitterUnit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &stereoStreamFormat, formatSize)
        guard check(status, "Could not Set StreamFormat input for Splitter Unit") else {
            return false
        }
        
        //配置VocalMixerUnit的属性
        status = AudioUnitSetProperty(mVocalMixerUnit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &stereoStreamFormat, formatSize)
        guard check(status, "Could not Set StreamFormat output for VocalMixer Unit") else {
            return false
        }
        status =  AudioUnitSetProperty(mVocalMixerUnit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &stereoStreamFormat, formatSize)
        guard check(status, "Could not Set StreamFormat input for VocalMixer Unit") else {
            return false
        }
        var mixerElementCount:Int32 = 1
        status = AudioUnitSetProperty(mVocalMixerUnit!, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &mixerElementCount, UInt32(MemoryLayout.stride(ofValue: mixerElementCount)))
        guard
            check(status, "Could not set mixerElementCount for  mVocalMixerUnit.")
        else { return false }
        
        //配置AccMixerUnit的属性
        status = AudioUnitSetProperty(mAccMixerUnit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &stereoStreamFormat, formatSize)
        guard check(status, "Could not Set StreamFormat output for mAccMixerUnit") else {
            return false
        }
        status = AudioUnitSetProperty(mAccMixerUnit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &stereoStreamFormat, formatSize)
        guard check(status, "Could not Set StreamFormat input for mAccMixerUnit") else {
            return false
        }
        mixerElementCount = 2
        status = AudioUnitSetProperty(mAccMixerUnit!, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &mixerElementCount, UInt32(MemoryLayout.stride(ofValue: mixerElementCount)))
        guard
            check(status, "Could not set mixerElementCount for  mAccMixerUnit.")
        else { return false }
        
        guard setInputSoures(isAAC: false) else {
            return false
        }
        //链接node
        status = AUGraphConnectNodeInput(mPlayerGraph, mPlayerNode, 0, mSplitterNode, 0)
        guard
            check(status, "Connect mPlayerNode 0 mSplitterNode 0 failed")
        else { return false }
        
        status = AUGraphConnectNodeInput(mPlayerGraph, mSplitterNode, 0, mVocalMixerNode, 0)
        guard
            check(status, "Connect mSplitterNode 0 mVocalMixerNode  0 failed")
        else { return false }
        
        status = AUGraphConnectNodeInput(mPlayerGraph, mSplitterNode, 1, mAccMixerNode, 0)
        guard
            check(status, "Connect mSplitterNode 1 mVocalMixerNode 0 failed")
        else { return false }
        
        status = AUGraphConnectNodeInput(mPlayerGraph, mVocalMixerNode, 0, mAccMixerNode, 1)
        guard
            check(status, "Connect mVocalMixerNode, 0, mAccMixerNode, 1 failed")
        else { return false }
        
        status = AUGraphConnectNodeInput(mPlayerGraph, mAccMixerNode, 0, mPlayerIONode, 0)
        guard
            check(status, "Connect mAccMixerNode, 0, mPlayerIONode, 0 failed")
        else { return false }
        
        //初始化graph
        status = AUGraphInitialize(mPlayerGraph)
        guard check(status, "Couldn't Initialize the graph") else {
            return false
        }
        //显示graph结构
        //CAShow(UnsafeMutableRawPointer.init(mPlayerGraph))
        //只有对Graph进行Initialize之后才可以设置AudioPlayer的参数
        guard setupFilePlayer() else {
            return false
        }
        return true
    }
    
    func addAudioSessionInterruptedObserver() {
        removeAudioSessionInterruptedObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationAudioInterrupted(_ :)), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance)
    }
    
    func removeAudioSessionInterruptedObserver() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    func play() -> Bool {
        guard
            let mPlayerGraph = self.mPlayerGraph,
            check(AUGraphStart(mPlayerGraph), "Could not start AUGraph")
        else {
            return false
        }
        return true
    }
    
    func stop() -> Bool {
        guard
            let mPlayerGraph = self.mPlayerGraph,
            check(AUGraphStop(mPlayerGraph), "Could not stop AUGraph")
        else {
            return false
        }
        return true
    }
}


//MARK: -
fileprivate
extension AUGraphPlayer {
    @objc func onNotificationAudioInterrupted(_ noti:NSNotification) {
        guard
            let interruptType = noti.userInfo?[AVAudioSessionInterruptionTypeKey] as? AVAudioSession.InterruptionType else {
                return
            }
        
        switch interruptType {
        case .began:
            _ = self.stop()
        case .ended:
            _ = self.play()
        @unknown default:
            debugPrint("其它 AVAudioSessionInterruption")
        }
    }
    
    func setupFilePlayer() -> Bool {
        var status = noErr
        var musicFile:AudioFileID? = nil
        let musisFileTypeSize = MemoryLayout.stride(ofValue: musicFile)
        debugPrint(musisFileTypeSize)
        // open the input audio file
        status = AudioFileOpenURL(playPath as CFURL, .readPermission, 0, &musicFile)
        guard
            check(status, "Open Audio file error"),
            musicFile != nil
        else {
            return false
        }
        // tell the file player unit to load the file we want to play
        status = AudioUnitSetProperty(mPlayerUnit!, kAudioUnitProperty_ScheduledFileIDs, kAudioUnitScope_Global, 0, &musicFile, UInt32(MemoryLayout.stride(ofValue: musicFile)))
        guard
            check(status, "Tell AudioFile Player Unit Load Which File... failed.")
        else { return false }
        
        var fileASBD = AudioStreamBasicDescription()
        var prosize:UInt32 = UInt32(MemoryLayout<AudioStreamBasicDescription>.stride)
        // get the audio data format from the file
        status = AudioFileGetProperty(musicFile!, kAudioFilePropertyDataFormat, &prosize, &fileASBD)
        
        guard
            check(status, "get the audio data format from the file... failed")
        else {
            debugPrint("获取文件格式信息错误")
            return false
        }
        var nPackets: UInt64 = 0
        prosize = UInt32(MemoryLayout.stride(ofValue: nPackets))
        status = AudioFileGetProperty(musicFile!, kAudioFilePropertyAudioDataPacketCount, &prosize, &nPackets)
        guard
            check(status, " get kAudioFilePropertyAudioDataPacketCount failed")
        else { return false }
        // tell the file player AU to play the entire file
        var timeStamp = AudioTimeStamp.init()
        timeStamp.mFlags = .sampleTimeValid
        timeStamp.mSampleTime = 0
        var rgn = ScheduledAudioFileRegion.init(mTimeStamp: timeStamp, mCompletionProc: nil, mCompletionProcUserData: nil, mAudioFile: musicFile! , mLoopCount: 0, mStartFrame: 0, mFramesToPlay: UInt32(nPackets) * (fileASBD.mFramesPerPacket))
        status = AudioUnitSetProperty(mPlayerUnit!, kAudioUnitProperty_ScheduledFileRegion, kAudioUnitScope_Global, 0, &rgn, UInt32(MemoryLayout.stride(ofValue: rgn)))
        debugPrint(MemoryLayout.stride(ofValue: rgn))
        guard
            check(status, "Prime Player Unit With Default Value... Failed")
        else { return false }
        // prime the file player AU with default values
        var defaultVal:UInt32 = 0
        status = AudioUnitSetProperty(mPlayerUnit!, kAudioUnitProperty_ScheduledFilePrime, kAudioUnitScope_Global, 0, &defaultVal, UInt32(MemoryLayout.stride(ofValue: defaultVal)))
        guard
            check(status, "Prime Player Unit Start Time...")
        else {
            return false
        }
        // tell the file player AU when to start playing (-1 sample time means next render cycle)
        var startTime:AudioTimeStamp = AudioTimeStamp()
        startTime.mFlags = .sampleTimeValid
        startTime.mSampleTime = -1
        status = AudioUnitSetProperty(mPlayerUnit!, kAudioUnitProperty_ScheduleStartTimeStamp, kAudioUnitScope_Global, 0, &startTime,UInt32(MemoryLayout.stride(ofValue: startTime)))
        guard
            check(status, "set player unit start time failed.") else {
                return false
            }
        return true
    }
    
    func setInputSoures(isAAC: Bool) -> Bool {
        var value:AudioUnitParameterValue = 0.0
        var status = AudioUnitGetParameter(mVocalMixerUnit!, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 0, &value)
        guard
            check(status, "Could not get parameter kMultiChannelMixerParam_Volume  0 for mVocalMixerUnit.")
        else { return false }
        debugPrint("Vocal Mixer \(value)")
        
        status = AudioUnitGetParameter(mAccMixerUnit!, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 0, &value)
        guard
            check(status, "Could not get parameter kMultiChannelMixerParam_Volume 0 for mAccMixerUnit.")
        else { return false }
        debugPrint("mAccMixerUnit 0 \(value)")
        
        status = AudioUnitGetParameter(mAccMixerUnit!, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 1, &value)
        guard
            check(status, "Could not get parameter kMultiChannelMixerParam_Volume 1 for mAccMixerUnit.")
        else { return false }
        debugPrint("mAccMixerUnit 1 \(value)")
        
//        if isAAC {
//            status = AudioUnitSetParameter(mAccMixerUnit!, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 0, 0.1, 0)
//            guard
//                check(status, "set kMultiChannelMixerParam_Volume failed for mAccMixerUnit 0.")
//            else { return false }
//            status = AudioUnitSetParameter(mAccMixerUnit!, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 1,1, 0)
//            guard
//                check(status, "set kMultiChannelMixerParam_Volume failed for mAccMixerUnit 1.")
//            else { return false }
//        } else {
//            status = AudioUnitSetParameter(mAccMixerUnit!, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 0,1,0)
//            guard
//                check(status, "set kMultiChannelMixerParam_Volume failed for mAccMixerUnit 0.")
//            else { return false }
//            status = AudioUnitSetParameter(mAccMixerUnit!, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 1,0.1,0)
//            guard
//                check(status, "set kMultiChannelMixerParam_Volume failed for mAccMixerUnit 1.")
//            else { return false }
//        }
        return true
        
    }
    
    func check(_ status:OSStatus,_ msg:String) -> Bool  {
        if status != noErr {
            debugPrint(msg)
            return false
        }
        return true
    }
}

fileprivate
extension AUGraphPlayer {
    
}
