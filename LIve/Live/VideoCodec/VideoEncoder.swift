//
//  VideoEncoder.swift
//  Live
//
//  Created by apple on 2022/3/28.
//

import Foundation
import UIKit
import VideoToolbox
import AVFoundation

class VideoEncoder {

    typealias Completion = (Data,Int) -> Void
    
    struct VideoFrame {
        var timestamp:UInt64
        var data:Data
        var header:Data
        var isKeyFrame:Bool
        var sps:Data
        var pps:Data
    }
    typealias VideoFrameGetter = (VideoFrame) -> Void
    
    let width:Int32
    let height: Int32
    let fps: Int32
    let bitRate: Int32

    var completionBlock:Completion? = nil
    var frameGetter:VideoFrameGetter? = nil
    
    init?(
        width:Int32,
        height: Int32,
        fps: Int32,
        bitRate: Int32
    ) {
        self.width = width
        self.height = height
        self.fps = fps
        self.bitRate = bitRate
        
        //设置解码属性
        
        //创建视频帧压缩Session
        
        guard let encoderSepecification = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, nil, nil) else {
            return nil
        }
        
        //开启低延时比率控制
//        if #available(iOS 14.5, *) {
//            var key = kVTVideoEncoderSpecification_EnableLowLatencyRateControl
//            var value = kCFBooleanTrue
//            CFDictionarySetValue(encoderSepecification, &key, &value)
//        }
     
        
        var s = self
        guard VTCompressionSessionCreate(allocator: nil, width: width, height: height, codecType: kCMVideoCodecType_H264, encoderSpecification: encoderSepecification, imageBufferAttributes: nil, compressedDataAllocator: nil, outputCallback: VTCompressSessionCallback, refcon: &s, compressionSessionOut: &compressionSession) == noErr,
        let session = compressionSession
        else {
            return nil
        }
        
     
        //设置关键帧间隔,即 gop size 一组图片间隔
        guard
            VTSessionSetProperty(session, key: kVTCompressionPropertyKey_MaxKeyFrameInterval, value: NSNumber(value: fps * 2)) == noErr else {
            debugPrint("设置关键帧间隔失败")
            return nil
        }
        guard
            VTSessionSetProperty(session, key: kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration, value: NSNumber(value: fps * 2)) == noErr else {
                debugPrint("设置关键帧间隔失败2")
                return nil
            }
        // 设置帧率，只用于初始化session，不是实际fps
        guard VTSessionSetProperty(session, key: kVTCompressionPropertyKey_ExpectedFrameRate, value: NSNumber(value: fps)) == noErr else {
            debugPrint("设置帧率失败")
            return nil
        }
        // 设置编码码率，如果不设置，默认将会以很低的码率编码，导致编码出来的视频很模糊
        guard
            VTSessionSetProperty(self, key: kVTCompressionPropertyKey_AverageBitRate, value: NSNumber(value: bitRate)) == noErr else {
                debugPrint("设置码率失败")
                return nil
            }
        
        let limit = NSArray.init(array: [
            NSNumber(value: Double(bitRate) * 1.5 / 8.0),
            NSNumber(value: 1)
        ])
        guard VTSessionSetProperty(session, key: kVTCompressionPropertyKey_DataRateLimits, value: limit) == noErr else {
            debugPrint("设置速率失败")
            return nil
        }
        guard
            VTSessionSetProperty(session, key: kVTCompressionPropertyKey_RealTime, value: kCFBooleanTrue) == noErr else {
                debugPrint("设置实时编码失败")
                return nil
            }
        
        
        // h264 profile, 直播一般使用baseline，可减少由于b帧带来的延时
       guard VTSessionSetProperty(session, key: kVTCompressionPropertyKey_ProfileLevel, value: kVTProfileLevel_H264_Baseline_AutoLevel) == noErr else {
            debugPrint("设置h264基线失败")
            return nil
        }
        
        // 防止编译B真是被自动重新排序
        guard VTSessionSetProperty(session, key: kVTCompressionPropertyKey_AllowFrameReordering, value: kCFBooleanFalse) == noErr else {
            return nil
        }
        
        // 设置H264 熵编码模式 H264标准采用了两种熵编码模式
        // 熵编码即编码过程中按熵原理不丢失任何信息的编码。信息熵为信源的平均信息量（不确定性的度量）
        guard VTSessionSetProperty(session, key: kVTCompressionPropertyKey_H264EntropyMode, value: kVTH264EntropyMode_CABAC) == noErr else {
            return nil
        }
//        if #available(iOS 15.0, *) {
//            //Request CBP
//            VTSessionSetProperty(session, key: kVTCompressionPropertyKey_ProfileLevel, value: kVTProfileLevel_H264_ConstrainedHigh_AutoLevel)
//
//            //Request CHP
//            VTSessionSetProperty(session, key: kVTCompressionPropertyKey_ProfileLevel, value: kVTProfileLevel_H264_ConstrainedHigh_AutoLevel)
//        }
     
        
        //开始编码
        guard VTCompressionSessionPrepareToEncodeFrames(session) == noErr else {
            debugPrint("准备编码失败")
            return nil
        }
        
    }
    
    static
    func getDefault() -> VideoEncoder {
        return VideoEncoder.init(width: 540, height: 960, fps: 24, bitRate: 800 * 1000)!
    }
    
    deinit {
        destoryVTCompressSessionIfNeeded()
    }
    
    
    private(set)
    var compressionSession:VTCompressionSession? = nil
    
    lazy private(set)
    var encodeQueue = DispatchQueue.init(label: "VideoEncoder.queue")
    
    private
    var frameCount = 0
    
    lazy fileprivate(set)
    var sps_jf:Data? = nil
    
    lazy fileprivate(set)
    var pps_jf:Data? = nil
    
    func encode(sampleBuffer:CMSampleBuffer,timeStamp:UInt64,completion:@escaping Completion) {
        self.completionBlock = completion
        encodeQueue.sync {
            guard
                let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
                let session = compressionSession
            else {
                return
            }
            
            frameCount += 1
            let pts = CMTimeMake(value: Int64(frameCount), timescale: 1000)
            let duration = CMTime.invalid
            var properties: NSDictionary? = nil
            
            if (frameCount % Int(fps) * 2 == 0) {
                properties = NSDictionary.init(dictionary: [
                    kVTEncodeFrameOptionKey_ForceKeyFrame:NSNumber(value: true)
                ])
            }
            var timeNumber = NSNumber.init(value: timeStamp)
            var flags:VTEncodeInfoFlags!
            
            
            if VTCompressionSessionEncodeFrame(session, imageBuffer: imageBuffer,
                                                  presentationTimeStamp: pts,
                                                  duration: duration, frameProperties: properties, sourceFrameRefcon: &timeNumber, infoFlagsOut: &flags) != noErr  {
                
                debugPrint("压缩帧失败")
                destoryVTCompressSessionIfNeeded()
            }
            
            
        }
    }
    
    
}

//MARK: - VTCompressSessionCallback
fileprivate
func  VTCompressSessionCallback(outputCallbackRefCon:UnsafeMutableRawPointer?, sourceFrameRefCon:UnsafeMutableRawPointer?,status: OSStatus,infoFlags: VTEncodeInfoFlags, sampleBuffer:CMSampleBuffer?) -> Void {
    guard
        status == noErr,
        let sf = outputCallbackRefCon?.load(as: VideoEncoder.self),
        let smplBuffer = sampleBuffer,
        let array = CMSampleBufferGetSampleAttachmentsArray(smplBuffer, createIfNecessary: true),
        let timeStamp = sourceFrameRefCon?.load(as: NSNumber.self)
    else {
        return
    }
    let dic = CFArrayGetValueAtIndex(array, 0).load(as: CFDictionary.self)
    
    var key = kCMSampleAttachmentKey_NotSync
    let isKeyFrame = CFDictionaryContainsKey(dic, &key)
    /**
      获取 sps pps 数据, sps pps 只需要获取一次, 保存在h.264文件开头即可
      SPS 对于H264而言，就是编码后的第一帧，如果是读取的H264文件，就是第一个帧界定符和第二个帧界定符之间的数据的长度是4
      PPS 就是编码后的第二帧，如果是读取的H264文件，就是第二帧界定符和第三帧界定符中间的数据长度不固定。
     */
    if (isKeyFrame && sf.sps_jf == nil) {
        var spsSize:size_t = 0,spsCount:size_t = 0
        var ppsSize:size_t = 0,ppsScount:size_t = 0
        
        guard let formatDesc = CMSampleBufferGetFormatDescription(smplBuffer) else {
            return
        }
        var spsDataPointer:UnsafePointer<UInt8>? = nil
        var ppsDataPointer:UnsafePointer<UInt8>? = nil
        guard
            CMVideoFormatDescriptionGetH264ParameterSetAtIndex(formatDesc, parameterSetIndex: 0, parameterSetPointerOut: &spsDataPointer, parameterSetSizeOut: &spsSize, parameterSetCountOut: &spsCount, nalUnitHeaderLengthOut: nil) == noErr,
            CMVideoFormatDescriptionGetH264ParameterSetAtIndex(formatDesc, parameterSetIndex: 1, parameterSetPointerOut: &ppsDataPointer, parameterSetSizeOut: &ppsSize, parameterSetCountOut: &ppsScount, nalUnitHeaderLengthOut: nil) == noErr,
                spsDataPointer != nil , ppsDataPointer != nil
        else {
            return
        }
        
        let sData = Data(bytes: spsDataPointer!, count: spsSize)
        let pData = Data(bytes: ppsDataPointer!, count: ppsSize)
        sf.sps_jf = sData
        sf.pps_jf = pData
        sf.write(h264Data: sData, lengt: spsSize)
        sf.write(h264Data: pData, lengt: ppsSize)
        
    }
    
    
    var lengthAtOffset:size_t = 0
    var totalLength:size_t = 0
    var data:UnsafeMutablePointer<CChar>? = nil
    guard
        let dataBuffer =  CMSampleBufferGetDataBuffer(smplBuffer),
        CMBlockBufferGetDataPointer(dataBuffer, atOffset: 0, lengthAtOffsetOut: &lengthAtOffset, totalLengthOut: &totalLength, dataPointerOut: &data) == noErr,
        data != nil
    else {
        return
    }
    
    var offset:size_t = 0
    //返回的nalu数据前四个字节不是0001的startcode，而是大端模式的帧长度length
    let lengthInfoSize = 4
    while offset < totalLength - lengthInfoSize {
        var naluLength:UInt32 = 0
         memcpy(&naluLength, data! + offset, lengthInfoSize)
        
        //大端模式转化为系统端模式
        naluLength = CFSwapInt32BigToHost(naluLength)
        
        let videoFrame = VideoEncoder.VideoFrame.init(
            timestamp: UInt64(truncating: timeStamp),
            data: Data.init(bytes: data! + offset + lengthInfoSize, count: Int(naluLength)), header: Data(), isKeyFrame: isKeyFrame, sps: sf.sps_jf!, pps: sf.pps_jf!)
        sf.frameGetter?(videoFrame)
        sf.write(h264Data: Data.init(bytes: data! + offset + lengthInfoSize, count: Int(naluLength)), lengt: Int(naluLength))
        
        offset += (lengthInfoSize + Int(naluLength))
    }
}


//MARK: - Private
extension VideoEncoder {
   private func destoryVTCompressSessionIfNeeded() {
        if let session = compressionSession {
            //强制结束编码
            VTCompressionSessionCompleteFrames(session, untilPresentationTimeStamp: CMTime.invalid)
            //使session失效
            VTCompressionSessionInvalidate(session)
            compressionSession = nil
        }
    }

    fileprivate
    func write(h264Data:Data ,lengt:Int) {
        let bytes:[UInt8] = [0x00,0x00,0x00,0x01]
        var data = Data()
        data.append(contentsOf: bytes)
        data.append(h264Data)
        completionBlock?(data,data.count)
        
    }
}

