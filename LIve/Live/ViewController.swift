//
//  ViewController.swift
//  LIve
//
//  Created by apple on 2022/3/28.
//

import UIKit
import AudioUnit
import AVFAudio
import Darwin

class ViewController: UIViewController {
    
    
    var auPlayer:AUGraphPlayer? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let v1:UInt16 = 0x1234
        let v2:UInt16 = (v1 & 0xff00) >> 8
        debugPrint(String(format: "%x", v2))
        
//        do {
//            let path = Bundle.main.path(forResource: "MiAmor", ofType: ".mp3")!
//            auPlayer = try AUGraphPlayer.init(filePath: path)
//        } catch let error {
//            debugPrint(error)
//        }
        
        //bytesCopyDemo()
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        do {
            //let path = Bundle.main.bundlePath.appending("/MiAmor.mp3")
            let path = Bundle.main.path(forResource: "MiAmor.mp3", ofType: nil)!
            debugPrint(path)
            auPlayer = try AUGraphPlayer.init(filePath: path)
            if auPlayer?.play() == true {
                debugPrint("play success")
            }
        } catch let error {
            debugPrint(error)
        }
        
    }
    
    func bytesCopyDemo() {
        
        let buffer:Data = Data.init([0x12,0x34,0x56,0x78])
        let bufferPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: buffer.count)
        defer {
            bufferPointer.deallocate()
        }
        buffer.copyBytes(to: bufferPointer, count: buffer.count)
        
        var data23 = Data.init(bytes: bufferPointer + 2 , count: buffer.count - 2)
        
        data23.withUnsafeMutableBytes { pointer in
            //直接操作Data中的数据
            let p = pointer.baseAddress!.bindMemory(to: UInt8.self, capacity: 2)
            p[0] = 0xff
        }
        
        
        func bytesStringsFrom(_ data:Data) -> [String] {
            return data.map({String.init(format: "%x", $0)})
        }
        
        debugPrint(bytesStringsFrom(buffer))
        debugPrint(bytesStringsFrom(data23))
        
    }
    
    
    func memoryLayoutOfUInt32Demo() {
        debugPrint("注意打印结果差别")
        var value32:UInt32 = 0x12345678 //78 56 34 12
        
        let pointer:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer.allocate(capacity: 4)
        defer { pointer.deallocate() }
        
        withUnsafeBytes(of: &value32) { p in
            let bytesPointer = p.baseAddress!.bindMemory(to: UInt8.self, capacity: MemoryLayout<UInt32>.stride)
            for i in 0..<MemoryLayout<UInt32>.stride {
                pointer[i] = bytesPointer[i]
            }
        }
        debugPrint("内存布局")
        for i in 0..<MemoryLayout<UInt32>.stride {
            debugPrint(NSString(format: "%x", pointer[i]))
        }
        
        //获取位数
        debugPrint("获取对应的位的值")
        let b0 = UInt8((value32 & 0xff000000) >> 24)
        let b1 = UInt8((value32 & 0x00ff0000) >> 16)
        let b2 = UInt8((value32 & 0x0000ff00) >> 8)
        let b3 = UInt8((value32 & 0x000000ff))
        debugPrint(NSString(format: "%x,%x,%x,%x", b0,b1,b2,b3))
    }
    
    func dataAndPointerDemo() {
        /**
         0xf1 = 241 = 1111_1000
         0x12 = 18  = 0001_0010
         */
        var datas:[UInt8] = [0xf1,0x12]
        
        var stream = Data.init(bytes: &datas, count: datas.count)
        
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: datas.count)
        stream.copyBytes(to: pointer, count: datas.count)
        
        defer {
            pointer.deinitialize(count: datas.count)
            pointer.deallocate()
        }
        
        pointer[1] = 0xfe
        //下面两种遍历方式.得到不同的结果
        //        do {
        //            ///1. 结果错误
        //            let bPointer = stream.withUnsafeMutableBytes {
        //                return $0.baseAddress!.bindMemory(to: UInt8.self, capacity: datas.count)
        //            }
        //            for i in 0..<datas.count {
        //                debugPrint(bPointer[i])
        //            }
        //
        //            ///2.
        //            /// 结果正确
        //            stream.withUnsafeMutableBytes { pointer in
        //                let bytesPointer = pointer.baseAddress!.bindMemory(to: UInt8.self, capacity: datas.count)
        //                for i in 0..<datas.count {
        //                    debugPrint(bytesPointer[i])
        //                }
        //            }
        //        }
        
        stream.withUnsafeMutableBytes { pointer in
            let bytesPointer = pointer.baseAddress!.bindMemory(to: UInt8.self, capacity: datas.count)
            bytesPointer[0] = 0xff
            for i in 0..<datas.count {
                debugPrint(bytesPointer[i])
            }
        }
        
        for i in 0..<datas.count {
            debugPrint(pointer[i])
        }
        
        debugPrint(datas,stream)
    }
    
}






//MARK: -
extension ViewController {
    func audioUnitDemo() {
        var ioUnitDescription = AudioComponentDescription()
        //指定大类型
        ioUnitDescription.componentType = kAudioUnitType_Output
        //指定具体类型
        ioUnitDescription.componentSubType = kAudioUnitSubType_RemoteIO
        //指定厂商信息, 固定值,目前只有apple
        ioUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple
        ioUnitDescription.componentFlags = 0
        ioUnitDescription.componentFlagsMask = 0
        
        
        guard
            let audioComponent = AudioComponentFindNext(nil, &ioUnitDescription)
        else { return }
        
        var ioUnitInstance:AudioUnit! = nil
        guard
            AudioComponentInstanceNew(audioComponent, &ioUnitInstance) == noErr,
            ioUnitInstance != nil
        else { return }
        
        
        // Declare and instantiate an audio processing graph
        var processingGraph:AUGraph! = nil
        guard
            NewAUGraph(&processingGraph) == noErr,
            processingGraph != nil
        else { return }
        
        // Add an audio unit node to the graph, then instantiate the audio unit
        var ioNode:AUNode! = nil
        guard
            AUGraphAddNode(processingGraph, &ioUnitDescription, &ioNode) == noErr,
            ioNode != nil
        else { return }
        
        // indirectly performs audio unit instantiation
        guard
            AUGraphOpen(processingGraph) == noErr
        else { return }
        
        // Obtain a reference to the newly-instantiated I/O unit
        var ioUnit:AudioUnit! = nil
        guard
            AUGraphNodeInfo(processingGraph, ioNode, &ioUnitDescription, &ioUnit) == noErr,
            ioUnit != nil
        else { return }
        
        var mixUnit:AudioUnit = ioUnit //混合单元
        var busCount:UInt32 = 2
        guard
            AudioUnitSetProperty(mixUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &busCount, UInt32(MemoryLayout.stride(ofValue: busCount))) == noErr
        else { return }
        
    }
    
    //文档地址:https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/AudioUnitHostingGuide_iOS/ConstructingAudioUnitApps/ConstructingAudioUnitApps.html#//apple_ref/doc/uid/TP40009492-CH16-SW1
    func constructingAudioUnitApps() {
        let graphSampleRate = 44100.0
        //1.配置AudioSession
        let audioSession = AVAudioSession.sharedInstance()
        do {
            //设置音频采样频率
            try  audioSession.setPreferredSampleRate(graphSampleRate)
            //设置音频类型
            try audioSession.setCategory(.playAndRecord)
            //激活session
            try audioSession.setActive(true, options: [])
            /**
             There’s one other hardware characteristic you may want to configure: audio hardware I/O buffer duration. The default duration is about 23 ms at a 44.1 kHz sample rate, equivalent to a slice size of 1,024 samples. If I/O latency is critical in your app, you can request a smaller duration, down to about 0.005 ms (equivalent to 256 samples)
             For a complete explanation of how to configure and use the audio session object, see Audio Session Programming Guide.
             */
            try audioSession.setPreferredIOBufferDuration(0.005)
        } catch let error {
            debugPrint(error)
            return
        }
        
        //2.执行想要的Auido Unit
        var ioUnitDesc = AudioComponentDescription.getWith(
            componentType: kAudioUnitType_Output,
            componentSubType: kAudioUnitSubType_RemoteIO
        )
        
        var mixerUnitDesc = AudioComponentDescription.getWith(
            componentType: kAudioUnitType_Mixer,
            componentSubType: kAudioUnitSubType_SpatialMixer
        )
        
        var processingGraph:AUGraph! = nil
        guard
            NewAUGraph(&processingGraph) == noErr,
            processingGraph != nil
        else {
            debugPrint("NewAUGraph failed!")
            return
        }
        
        //获取node
        var ioNode:AUNode! = nil
        guard
            AUGraphAddNode(processingGraph, &ioUnitDesc, &ioNode) == noErr,
            ioNode != nil
        else {
            debugPrint("Add io node failed!")
            return
        }
        
        var mixerNode:AUNode! = nil
        guard
            AUGraphAddNode(processingGraph, &mixerUnitDesc, &mixerNode) == noErr,
            mixerNode != nil
        else {
            debugPrint("Add mixer node failed!")
            return
        }
        
        //To open the graph and instantiate the audio units
        guard AUGraphOpen(processingGraph) == noErr else {
            debugPrint("Open graph failed!")
            return
        }
        
        
        //获取Audio Unit
        var ioUnit:AudioUnit! = nil
        var mixerUnit: AudioUnit! = nil
        guard
            AUGraphNodeInfo(processingGraph, ioNode, nil, &ioUnit) == noErr,
            AUGraphNodeInfo(processingGraph, mixerNode, nil, &mixerUnit) == noErr,
            ioUnit != nil , mixerUnit != nil
        else {
            debugPrint("获取unit失败")
            return
        }
        
        /**
         Configure the Audio Units
         Each iOS audio unit requires its own configuration, as described in Using Specific Audio Units. However, some configurations are common enough that all iOS audio developers should be familiar with them.
         
         The Remote I/O unit, by default, has output enabled and input disabled. If your app performs simultaneous I/O, or uses input only, you must reconfigure the I/O unit accordingly. For details, see the kAudioOutputUnitProperty_EnableIO property in Audio Unit Properties Reference.
         
         All iOS audio units, with the exception of the Remote I/O and Voice-Processing I/O units, need their kAudioUnitProperty_MaximumFramesPerSlice property configured. This property ensures that the audio unit is prepared to produce a sufficient number of frames of audio data in response to a render call. For details, see kAudioUnitProperty_MaximumFramesPerSlice in Audio Unit Properties Reference.
         
         All audio units need their audio stream format defined on input, output, or both. For an explanation of audio stream formats, see Audio Stream Formats Enable Data Flow. For the specific stream format requirements of the various iOS audio units, see Using Specific Audio Units.
         */
        
        //Write and Attach Render Callback Functions
        var callbackStruct = AURenderCallbackStruct()
        callbackStruct.inputProc = AudioRenderInputProc
        callbackStruct.inputProcRefCon = Unmanaged.passUnretained(self).toOpaque()
        AudioUnitSetProperty(ioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callbackStruct, UInt32(MemoryLayout.stride(ofValue: callbackStruct)))
        
        
        //You can attach a render callback in a thread-safe manner, even when audio is flowing, by using the audio processing graph API.Below shows how.
        do {
            AUGraphSetNodeInputCallback(processingGraph, ioNode, 0, &callbackStruct)
            var updated:DarwinBoolean = false
            AUGraphUpdate(processingGraph, &updated)
        }
        
        //Connect the Audio Unit Nodes
        var mixerUnitOutputBus:AudioUnitElement = 0
        var ioUnitOutputElement:AudioUnitElement = 0
        
        //将mixerNode的输出链接到ioUnit的输出(直接播放)
        AUGraphConnectNodeInput(processingGraph, mixerNode, mixerUnitOutputBus, ioNode, ioUnitOutputElement)
        
        //Initialize and Start the Audio Processing Graph
        guard
            AUGraphInitialize(processingGraph) == noErr,
            AUGraphStart(processingGraph) == noErr else {
            debugPrint("Initialize and start graph failed.")
            return
        }
        
        //Some time later
        AUGraphStop(processingGraph)
    }
}


fileprivate
func AudioRenderInputProc
(
 inRefCon:UnsafeMutableRawPointer,
 ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
 inTimeStamp:UnsafePointer<AudioTimeStamp>,
 inBusNumber: UInt32,
 inNumberFrames: UInt32,
 ioData:UnsafeMutablePointer<AudioBufferList>?
)
-> OSStatus {
    return noErr
}


