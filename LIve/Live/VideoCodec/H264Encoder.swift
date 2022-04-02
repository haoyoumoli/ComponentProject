//
//  VEVideoEncoder.swift
//  Live
//
//  Created by apple on 2022/3/29.
//

import Foundation
import CoreMedia
import VideoToolbox

protocol H264EncoderDelegate:AnyObject {
    func H264Encoder(_ encoder:H264Encoder,didEncodedData data:Data, isKeyFrame:Bool)
}

//MARK: - 
class H264Encoder {
    
    struct EncodeParam {
        
        enum ProfileLevel {
            case auto
            case bp
            case mp
            case hp
        }
        /// profile level
        var profileLevel:ProfileLevel = .auto
        /// 编码帧宽度
        var encodeWidth: Int32 = 320
        /// 编码帧高度
        var encodeHeight: Int32 = 480
        ///  编码类型
        var encodeType:CMVideoCodecType = kCMVideoCodecType_H264
        /// 码率 单位kbps
        var bitRate:Int32 = 1024 * 512
        /// 帧率 单位fps,缺省为15fps
        var frameRate:Int32 = 15
        /// 最大I帧间隔,单位秒
        var maxKeyFrameInterval:Int32 = 240
        /// 是否允许产生B帧
        var allowFrameReordering = false
    }
    
    
    let encodeParam:EncodeParam
    
    weak
    var delegate:H264EncoderDelegate? = nil
    
    init(encodeParam:EncodeParam) {
        self.encodeParam = encodeParam
    }
    
    deinit {
        destorySession()
    }
    
    lazy private(set)
    var session:VTCompressionSession? = nil
}


//MARK: - interface
extension H264Encoder {
    func prepareSession() -> Bool {
        if session != nil {
            return true
        }
        // 创建session
        guard
            VTCompressionSessionCreate(allocator: nil, width: encodeParam.encodeWidth, height: encodeParam.encodeHeight, codecType: encodeParam.encodeType, encoderSpecification: nil, imageBufferAttributes: nil, compressedDataAllocator: nil, outputCallback: VTCompressSessionCallback, refcon: Unmanaged.passUnretained(self).toOpaque(), compressionSessionOut: &session) == noErr,
            session != nil else {
                debugPrint("创建VTCompressionSession失败")
                return false
            }
        
        guard adjustBitRate(encodeParam.bitRate) else {
            return false
        }
        guard
            VTSessionSetProperty(session!, key: kVTCompressionPropertyKey_ProfileLevel, value: getVTProfileLevel(encodeParam.profileLevel)) == noErr else {
                debugPrint("设置profile level 失败")
                return false
            }
        guard
            VTSessionSetProperty(session!, key: kVTCompressionPropertyKey_RealTime, value: kCFBooleanTrue) == noErr else {
                debugPrint("开启实时编码压缩失败")
                return false
            }
        
        // 配置是否产生B帧
        guard
            VTSessionSetProperty(session!, key: kVTCompressionPropertyKey_AllowFrameReordering, value: encodeParam.allowFrameReordering ? kCFBooleanTrue : kCFBooleanFalse) == noErr else {
                debugPrint("设置kVTCompressionPropertyKey_AllowFrameReordering失败")
                return false
            }
        
        guard VTSessionSetProperty(session!, key: kVTCompressionPropertyKey_MaxKeyFrameInterval, value: NSNumber(value: encodeParam.maxKeyFrameInterval)) == noErr else {
            debugPrint("设置I帧间隔失败")
            return false
        }
        
        guard VTCompressionSessionPrepareToEncodeFrames(session!) == noErr else {
            debugPrint("准备解码失败")
            return false
        }
        return true
    }
    
    
    func encodeSampleBuffer(_ buffer:CMSampleBuffer, forceKeyFrame:Bool) -> Bool  {
        guard prepareSession() else {
            return false
        }
        let frameProperties = [
            kVTEncodeFrameOptionKey_ForceKeyFrame:NSNumber(value: forceKeyFrame)
        ] as? CFDictionary
        guard
            let pixelBuffer = CMSampleBufferGetImageBuffer(buffer),
            VTCompressionSessionEncodeFrame(session!, imageBuffer: pixelBuffer, presentationTimeStamp: .invalid, duration: .invalid, frameProperties: frameProperties, sourceFrameRefcon: nil, infoFlagsOut: nil) == noErr
        else {
            debugPrint("VTCompressionSessionEncodeFrame 失败")
            return false
        }
        return true
    }
    
    func destorySession() {
        guard let ss = session else { return }
        VTCompressionSessionCompleteFrames(ss, untilPresentationTimeStamp: .invalid)
        VTCompressionSessionInvalidate(ss)
        session = nil
    }
}

//MARK: -
private
extension H264Encoder {
    func adjustBitRate(_ rate:Int32) -> Bool {
        guard session != nil,rate > 0 else {
            return false
        }
        //设置平均码率
        guard VTSessionSetProperty(session!, key: kVTCompressionPropertyKey_AverageBitRate, value: NSNumber(value: rate)) == noErr else {
            return false
        }
        
        //参考webRTC ,限制最大码率不超过平均码率的1.5倍
        var dataLimitBytesPerSecondValue = Int64(Double(rate) * 1.5) / 8
      
        var oneSecondValue = 1
        
       guard let bytesPerSecond = CFNumberCreate(kCFAllocatorDefault, CFNumberType.sInt16Type, &dataLimitBytesPerSecondValue),
        let oneSecond = CFNumberCreate(kCFAllocatorDefault, .sInt16Type, &oneSecondValue) else {
            return false
        }
        
        //一秒的码率(平局码率)
        let limitValues = NSArray.init(array: [bytesPerSecond,oneSecond])
            
        guard VTSessionSetProperty(session!, key: kVTCompressionPropertyKey_DataRateLimits, value: limitValues as CFArray) == noErr else {
            return false
        }
        
        return true
    }
    
    func getVTProfileLevel(_ profileLevel:EncodeParam.ProfileLevel) -> CFString {
        switch profileLevel {
        case .auto:
            return kVTProfileLevel_H264_Baseline_AutoLevel
        case .bp:
            return kVTProfileLevel_H264_Baseline_3_1
        case .mp:
            return kVTProfileLevel_H264_Main_3_1
        case .hp:
            return kVTProfileLevel_H264_High_3_1
        }
    }
    
    func notifyData(data:Data,isKeyFrame:Bool) {
        var header:[UInt8] = [0x00,0x00,0x00,0x01]
        let headerData = Data.init(bytes: &header, count: 4)
        var resultData = Data()
        resultData.append(headerData)
        resultData.append(data)
        delegate?.H264Encoder(self, didEncodedData: resultData,isKeyFrame: isKeyFrame)
    }
    
}


//MARK: -
fileprivate
func  VTCompressSessionCallback(outputCallbackRefCon:UnsafeMutableRawPointer?, sourceFrameRefCon:UnsafeMutableRawPointer?,status: OSStatus,infoFlags: VTEncodeInfoFlags, sampleBuffer:CMSampleBuffer?) -> Void {
    
    guard
        status == noErr,
        let smplbuf = sampleBuffer,
        CMSampleBufferDataIsReady(smplbuf),
        //不是被丢弃的帧
        infoFlags.contains(VTEncodeInfoFlags.frameDropped) == false,
        let sampleAttachmentsArray = CMSampleBufferGetSampleAttachmentsArray(smplbuf, createIfNecessary: true)
    else {
        debugPrint("VTCompressSessionCallback error")
        return
    }
 
    let encoder = unsafeBitCast(outputCallbackRefCon!, to: H264Encoder.self)
    
    let cfdic = unsafeBitCast(CFArrayGetValueAtIndex(sampleAttachmentsArray, 0), to: CFDictionary.self)
    

   let isKeyFrame = CFDictionaryContainsKey(cfdic, Unmanaged.passUnretained(kCMSampleAttachmentKey_NotSync).toOpaque()) == false
    
    if
        isKeyFrame,
        let formatDesc = CMSampleBufferGetFormatDescription(smplbuf)
    {
        debugPrint("编码了关键帧")
      
        var spsData:UnsafePointer<UInt8>? = nil
        var spsSize:Int = 0
        var spsCount:Int = 0
        var ppsData:UnsafePointer<UInt8>? = nil
        var ppsSize:Int = 0
        var ppsCount:Int = 0
        //关键帧需要加上SPS,PPS信息
        if
            CMVideoFormatDescriptionGetH264ParameterSetAtIndex(formatDesc, parameterSetIndex: 0, parameterSetPointerOut: &spsData, parameterSetSizeOut: &spsSize, parameterSetCountOut: &spsCount, nalUnitHeaderLengthOut: nil) == noErr,
            CMVideoFormatDescriptionGetH264ParameterSetAtIndex(formatDesc, parameterSetIndex: 1, parameterSetPointerOut: &ppsData, parameterSetSizeOut: &ppsSize, parameterSetCountOut: &ppsCount, nalUnitHeaderLengthOut: nil) == noErr,
           ppsData != nil ,spsData != nil
         {
            encoder.notifyData(data: Data.init(bytes: spsData!, count: spsSize),isKeyFrame: isKeyFrame)
            encoder.notifyData(data: Data.init(bytes: ppsData!, count: ppsSize),isKeyFrame: isKeyFrame)
         }
    }
    
    var lengthAtOffset:Int = 0
    var totalLength:Int = 0
    var dataPointer:UnsafeMutablePointer<CChar>? = nil
    guard
        let blockBuf = CMSampleBufferGetDataBuffer(smplbuf),
        CMBlockBufferGetDataPointer(blockBuf, atOffset: 0, lengthAtOffsetOut: &lengthAtOffset, totalLengthOut: &totalLength, dataPointerOut: &dataPointer) == noErr,
        dataPointer != nil
    else {
           debugPrint("获取blockbuf数据失败")
            return
        }
    
    var bufferOffSet:size_t = 0
    let avcHeaderLength = 4
    while bufferOffSet < (totalLength - avcHeaderLength) {
        //获取NAL单元长度
        var nalunitLength:UInt32 = 0
        memcpy(&nalunitLength, dataPointer! + bufferOffSet, avcHeaderLength)
        
        nalunitLength = CFSwapInt32BigToHost(nalunitLength)
        
        let frameData = Data.init(bytes: dataPointer! + (bufferOffSet + avcHeaderLength), count: Int(nalunitLength))
        encoder.notifyData(data: frameData,isKeyFrame:isKeyFrame)
        bufferOffSet += (avcHeaderLength + Int(nalunitLength))
    }
}
