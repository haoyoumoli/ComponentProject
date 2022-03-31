//
//  H264Decoder.swift
//  Live
//
//  Created by apple on 2022/3/29.
//

import Foundation
import VideoToolbox
import AVFoundation

protocol H264DecoderDelegate:AnyObject {
    func H264Decoder(_ decoder:H264Decoder,didDecompress pixelBuffer:CVImageBuffer, sampleBuffer:CMSampleBuffer )
}

//MARK: -
class H264Decoder {
    
    weak
    var delegate:H264DecoderDelegate? = nil
    
    init() {
        
    }
    
    deinit {
        ppsDataPointer?.deallocate()
        spsDataPointer?.deallocate()
        destorySession()
    }
    
    lazy private(set)
    var session:VTDecompressionSession? = nil
    
    lazy private(set)
    var decoderFormatDescription:CMFormatDescription? = nil
    
    lazy private(set)
    var spsDataPointer:UnsafePointer<UInt8>? = nil
    
    lazy private(set)
    var spsSize: Int = 0
    
    lazy private(set)
    var ppsDataPointer:UnsafePointer<UInt8>? = nil
    
    lazy private(set)
    var ppsSize:Int = 0
}


//MARK: - Interface

extension H264Decoder {
    
    func decode(naluData:Data) {

        //多进行了一次拷贝
        let frameSize = UInt32(naluData.count)
        let frame = UnsafeMutablePointer<UInt8>.allocate(capacity: naluData.count)
        naluData.copyBytes(to: frame, count: naluData.count)

        defer {
            frame.deinitialize(count: Int(frameSize))
            frame.deallocate()
        }
        //let frame = p.baseAddress!.bindMemory(to: UInt8.self, capacity: naluData.count)

        // frame的前4位是NALU数据的开始码，也就是00 00 00 01，第5个字节是表示数据类型，转为10进制后，7是sps,8是pps,5是IDR（I帧）信息
        let naluType = (frame[4] & 0x1F)
       
        // 将NALU的开始码替换成NALU的长度信息
        //https://blog.csdn.net/chenchong_219/article/details/37990541
        let nalSize = frameSize - 4
        //0x12345678 的内存布局是  78 56 34 12,小端模式反着取
        frame[0] =  UInt8((nalSize & 0xff000000) >> 24)
        frame[1] =  UInt8((nalSize & 0x00ff0000) >> 16)
        frame[2] =  UInt8((nalSize & 0x0000ff00) >> 8)
        frame[3] =  UInt8(nalSize & 0x000000ff)

        switch naluType {
            //I帧
        case 0x05:
            if prepareSession() {
                debugPrint("解码I帧")
                decode(frame: frame, frameSize: frameSize)
            }
            //SPS
        case 0x07:
            debugPrint("解码SPS")
            spsSize = Int(frameSize - 4)
            //释放旧数据
            spsDataPointer?.deallocate()
            let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: spsSize)
            memcpy(pointer, frame + 4, spsSize)
            spsDataPointer = UnsafePointer<UInt8>(pointer)
            //PPS
        case 0x08:
            debugPrint("解码PPS")
            ppsSize = Int(frameSize - 4)
            //释放旧数据
            ppsDataPointer?.deallocate()
            let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: ppsSize)
            memcpy(pointer, frame + 4, ppsSize)
            ppsDataPointer = UnsafePointer<UInt8>(pointer)

            // B帧或者P帧
        default :
            if prepareSession() {
                debugPrint("解码B帧或者P帧")
                decode(frame: frame, frameSize: frameSize)
            }
        }
    }
}

//MARK: - private
private
extension H264Decoder {
    
    //构造CMSampleBuffer解码
    func decode(frame:UnsafeMutablePointer<UInt8>,frameSize:UInt32) {
        var blockBuffer:CMBlockBuffer? = nil
        
        guard
            session != nil ,
            //创建CMBlockBuffer(为解码的数据)
            CMBlockBufferCreateWithMemoryBlock(allocator: nil, memoryBlock: frame, blockLength: Int(frameSize), blockAllocator: kCFAllocatorNull, customBlockSource: nil, offsetToData: 0, dataLength: Int(frameSize), flags: 0, blockBufferOut: &blockBuffer) == noErr,
            blockBuffer != nil else {
                debugPrint("CMBlockBufferCreateWithMemoryBlock失败")
                return
            }
        
        var sampleSizeArray = [Int(frameSize)]
        var sampleBuffer:CMSampleBuffer? = nil
        // 创建CMSampleBuffer
        guard CMSampleBufferCreateReady(allocator: kCFAllocatorDefault, dataBuffer: blockBuffer, formatDescription: decoderFormatDescription, sampleCount: 1, sampleTimingEntryCount: 0, sampleTimingArray: nil, sampleSizeEntryCount: 1, sampleSizeArray: &sampleSizeArray, sampleBufferOut: &sampleBuffer) == noErr,
              sampleBuffer != nil
        else {
            debugPrint("CMSampleBufferCreateReady 失败")
            return
        }
        
        var flagOut:VTDecodeInfoFlags = []
        
        //解码CMSampleBuffer
        let status =
        VTDecompressionSessionDecodeFrame(session!, sampleBuffer: sampleBuffer!, flags: [], frameRefcon: nil, infoFlagsOut: &flagOut)
        if status == noErr {
            debugPrint("VTDecompressionSessionDecodeFrame 成功")
        } else if status == kVTInvalidSessionErr {
            debugPrint("kVTInvalidSessionErr")
        } else if status == kVTVideoDecoderBadDataErr {
            debugPrint("kVTVideoDecoderBadDataErr")
        }
        
    }
    
    func prepareSession() -> Bool {
        if session != nil {
            return true
        }
        
        guard let spsP = spsDataPointer , let ppsP = ppsDataPointer else {
            return false
        }
        
        var parameterSetPointers = [spsP,ppsP]
        var parameterSetSizesPointer = [spsSize,ppsSize]
        
        guard CMVideoFormatDescriptionCreateFromH264ParameterSets(allocator: kCFAllocatorDefault, parameterSetCount: 2, parameterSetPointers: &parameterSetPointers, parameterSetSizes: &parameterSetSizesPointer, nalUnitHeaderLength: 4, formatDescriptionOut: &decoderFormatDescription) == noErr,
              decoderFormatDescription != nil
        else {
            debugPrint("CMVideoFormatDescriptionCreateFromH264ParameterSets 返回失败")
            return false
        }
        
        // 从sps pps中获取解码视频的宽高信息
        let demensions = CMVideoFormatDescriptionGetDimensions(decoderFormatDescription!)
        
        // kCVPixelBufferPixelFormatTypeKey 解码图像的采样格式
        // kCVPixelBufferWidthKey、kCVPixelBufferHeightKey 解码图像的宽高
        // kCVPixelBufferOpenGLCompatibilityKey制定支持OpenGL渲染，经测试有没有这个参数好像没什么差别
        let destinnationPixelBufferAttributes = [
            kCVPixelBufferPixelFormatTypeKey:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
            kCVPixelBufferWidthKey:demensions.width,
            kCVPixelBufferHeightKey:demensions.height,
            kCVPixelBufferOpenGLCompatibilityKey:true
        ] as? CFDictionary
        
        var callbackRecored = VTDecompressionOutputCallbackRecord.init()
        callbackRecored.decompressionOutputCallback = funcVTDecompressionOutputCallback
        callbackRecored.decompressionOutputRefCon = Unmanaged.passUnretained(self).toOpaque()
        
        //创建解码器
        guard VTDecompressionSessionCreate(
            allocator: kCFAllocatorDefault,
            formatDescription: decoderFormatDescription!,
            decoderSpecification: nil,
            imageBufferAttributes: destinnationPixelBufferAttributes,
            outputCallback: &callbackRecored,
            decompressionSessionOut: &session) == noErr,
              session != nil
        else {
            debugPrint("创建解码器失败")
            return false
        }
        
        //设置解码线程数量
        //        guard VTSessionSetProperty(session!, key: kVTDecompressionPropertyKey_ThreadCount, value: NSNumber(value: 1)) == noErr else {
        //            debugPrint("设置解码线程数量失败")
        //            return false
        //        }
        
        //开启实时解码
        guard
            VTSessionSetProperty(session!, key: kVTDecompressionPropertyKey_RealTime, value: kCFBooleanTrue) == noErr else {
                debugPrint("设置实时解码失败")
                return false
            }
        
        
        return true
    }
    
    func destorySession() {
        guard session != nil else {
            return
        }
        VTDecompressionSessionInvalidate(session!)
    }
}


fileprivate
func funcVTDecompressionOutputCallback(
    decompressionOutputRefCon:UnsafeMutableRawPointer?,
    sourceFrameRefCon:UnsafeMutableRawPointer?,
    status:OSStatus,
    infoFlags:VTDecodeInfoFlags,
    imageBuffer:CVImageBuffer?,
    presentationTimeStamp: CMTime,
    presentationDuration: CMTime)
-> Void {
    
    status.debugPrint()
    guard
        status == noErr,
        let dopRefcon = decompressionOutputRefCon,
        let imgBuf = imageBuffer
    else {
        debugPrint("funcVTDecompressionOutputCallback 失败")
        return
    }
    
    let decoder = unsafeBitCast(dopRefcon, to: H264Decoder.self)
    
    var formatDesc: CMVideoFormatDescription? = nil
    
    
    guard
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: imgBuf, formatDescriptionOut: &formatDesc) == noErr,
        formatDesc != nil
    else {
        debugPrint("CMVideoFormatDescriptionCreateForImageBuffer failed")
        return
    }
    
    var sampleBuffer:CMSampleBuffer? = nil
    var smapleTimgInfo = CMSampleTimingInfo()
    smapleTimgInfo.presentationTimeStamp = presentationTimeStamp
    guard CMSampleBufferCreateReadyWithImageBuffer(allocator:  kCFAllocatorDefault, imageBuffer: imgBuf, formatDescription: formatDesc!, sampleTiming: &smapleTimgInfo, sampleBufferOut: &sampleBuffer) == noErr,
          sampleBuffer != nil
    else  {
        debugPrint("CMVideoFormatDescriptionCreateForImageBuffer failed")
        return
    }
    decoder.delegate?.H264Decoder(decoder, didDecompress: imgBuf,sampleBuffer: sampleBuffer!)
}
