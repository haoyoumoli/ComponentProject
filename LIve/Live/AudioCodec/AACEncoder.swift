//
//  AACEncoder.swift
//  Live
//
//  Created by apple on 2022/3/31.
//

import Foundation
import AudioUnit
import CoreAudio
import CoreMedia
import AudioToolbox
import CoreFoundation
import Darwin

class AACEncoder {
    
    init() {
        aacBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: aacBufferSize)
    }
    
    deinit {
        pcmBuffer?.deinitialize(count: pcmBufferSize)
        pcmBuffer?.deallocate()
        aacBuffer.deinitialize(count: aacBufferSize)
        aacBuffer.deallocate()
        if let a = audioConverter {
            AudioConverterDispose(a)
        }
    }
    
    private var audioConverter:AudioConverterRef? = nil
    private var pcmBuffer:UnsafeMutablePointer<CChar>? = nil
    private var pcmBufferSize:size_t = 1024
    private var aacBuffer:UnsafeMutablePointer<CChar>
    private var aacBufferSize:size_t = 0
    lazy private var lock:DispatchSemaphore = DispatchSemaphore.init(value: 1)
    lazy private(set)
    var encoderQueue:DispatchQueue = DispatchQueue.init(label: "AACEncoder.encoderQueue")
    lazy private(set)
    var callbackQueue:DispatchQueue = DispatchQueue.init(label: "AACEncoder.callbackQueue")
}

//MARK: - Subtypes
extension AACEncoder {
    
}

//MARK: - Interface
extension AACEncoder {
    typealias Completion = (Data?,Error?) -> Void
    
    enum EncodeErr:Error {
        case CMSampleBufferGetDataBuffer
        case AudioConverterFillComplexBuffer
    }
    
    func encode(
        sampleBuffer:CMSampleBuffer,
        timestamp:UInt64,
        completion: @escaping Completion
    ) {
        encoderQueue.async { [weak self] in
            guard let sf = self else { return }
            //创建convert
            if sf.audioConverter == nil {
                sf.prepareConverter(for: sampleBuffer)
            }
            var pcmbufSize:Int = 0
            var pcmbufPointer:UnsafeMutablePointer<CChar>? = nil
            guard
                let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer),
                //拿到PCM数据
                CMBlockBufferGetDataPointer(blockBuffer, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &pcmbufSize, dataPointerOut: &pcmbufPointer) == kCMBlockBufferNoErr,
                pcmbufPointer != nil
            else {
                sf.callbackQueue.async {
                    completion(nil,EncodeErr.CMSampleBufferGetDataBuffer)
                }
                return
            }
            sf.pcmBuffer = pcmbufPointer
            sf.pcmBufferSize = pcmbufSize
            
            memset(sf.aacBuffer, 0, sf.aacBufferSize)
            
            //设置aac数据缓冲区
            var outAudioBufferList = AudioBufferList()
            outAudioBufferList.mNumberBuffers = 1
            var audioBufer = AudioBuffer()
            audioBufer.mData = UnsafeMutableRawPointer(sf.aacBuffer)
            audioBufer.mDataByteSize = UInt32(sf.aacBufferSize)
            audioBufer.mNumberChannels = 1
            outAudioBufferList.mBuffers = (audioBufer)
            
            var outPacketDescription:AudioStreamPacketDescription! = nil
            var ioOutputDataPacketSize:UInt32 = 1
            // Converts data supplied by an input callback function, supporting non-interleaved and packetized formats.
            // Produces a buffer list of output data from an AudioConverter. The supplied input callback function is called whenever necessary.
            //进行解码
            guard AudioConverterFillComplexBuffer(sf.audioConverter!, fAudioConverterComplexInputDataProc, Unmanaged.passUnretained(sf).toOpaque(), &ioOutputDataPacketSize, &outAudioBufferList, &outPacketDescription) == noErr else  {
                sf.callbackQueue.async {
                    completion(nil,EncodeErr.AudioConverterFillComplexBuffer)
                }
                debugPrint("AudioConverterFillComplexBuffer failed")
                return
            }
            var data = Data()
           
            //构造aac结构
            let rawAAC = Data.init(bytes: outAudioBufferList.mBuffers.mData!, count: Int(outAudioBufferList.mBuffers.mDataByteSize))
            data.append(sf.asdtData(for: Int32(rawAAC.count)))
            data.append(rawAAC)
            
            
            
//            //flv编码音频头 44100 为0x12 0x10
//            var asc = Data(count: 2)
//            asc.withUnsafeMutableBytes { buf in
//                let pointer = buf.baseAddress!.bindMemory(to: UInt8.self, capacity: 2)
//                pointer[0] = 0x10 | ((4>>1) | 0x3)
//                pointer[1] = ((4 & 0x1) << 7) | ((1 & 0xf) << 3)
//            }
            
            
            sf.callbackQueue.async {
                completion(data,nil)
            }
        }
    }
}

//MARK: -
fileprivate
func fAudioConverterComplexInputDataProc(
    inAudioConverter:AudioConverterRef,
    ioNumberDataPackets:UnsafeMutablePointer<UInt32>,
    ioData: UnsafeMutablePointer<AudioBufferList>,
    outDataPacketDescription:UnsafeMutablePointer<UnsafeMutablePointer<AudioStreamPacketDescription>?>?,
    inUserData: UnsafeMutableRawPointer?) -> OSStatus
{
    
    let encoder = unsafeBitCast(ioData, to: AACEncoder.self)
    let requestedPackets = ioNumberDataPackets.pointee
    let copiedSamples = encoder.copyPCMSamplesIntoBuffer(ioData: ioData.pointee)
    if (copiedSamples < requestedPackets) {
        ioNumberDataPackets.pointee = 0
        return -1
    }
    ioNumberDataPackets.pointee = 1
    return noErr
}

//MARK: -
fileprivate
extension AACEncoder {
    
    func copyPCMSamplesIntoBuffer(ioData:AudioBufferList) -> size_t {
        var ioData = ioData
        let originalBUfferSize = pcmBufferSize
        if originalBUfferSize == 0 {
            return 0
        }
        ioData.mBuffers.mData = UnsafeMutableRawPointer(pcmBuffer)
        ioData.mBuffers.mDataByteSize = UInt32(pcmBufferSize)
        pcmBuffer = nil
        pcmBufferSize = 0
        return originalBUfferSize
    }
    
    
    /**
     *  Add ADTS header at the beginning of each and every AAC packet.
     *  This is needed as MediaCodec encoder generates a packet of raw
     *  AAC data.
     *
     *  Note the packetLen must count in the ADTS header itself.
     *  See: http://wiki.multimedia.cx/index.php?title=ADTS
     *  Also: http://wiki.multimedia.cx/index.php?title=MPEG-4_Audio#Channel_Configurations
     **/
    func asdtData(for packetLen:Int32)  -> Data {
        let adtsLen:Int32 = 7
        var data = Data.init(count: Int(adtsLen))
        // Variables Recycled by addADTStoPacket
        //https://wiki.multimedia.cx/index.php/MPEG-4_Audio#Audio_Object_Types
        // profile AAC_LC
        let profile:Int32 = 2
        //39=MediaCodecInfo.CodecProfileLevel.AACObjectELD
        //采样频率表示, 4 表示44100Hz
        let freqIdx:Int32 = 4
        let chanCfg:Int32 = 1
        let fullLen:Int32 = adtsLen + packetLen
        data.withUnsafeMutableBytes { pointer in
            let start = pointer.baseAddress!.bindMemory(to: UInt8.self, capacity: Int(adtsLen))
            // 11111111     = syncword
            start[0] = 0xff
            // 1111 | 1001  = syncword MPEG-2 Layer CRC
            start[1] = 0xf9
            start[2] = UInt8(((profile - 1) << 6) + (freqIdx << 2) + (chanCfg >> 2))
            start[3] = UInt8(((chanCfg & 3) << 6) + (fullLen >> 11))
            start[4] = UInt8((fullLen & 0x7ff) >> 3)
            start[5] = UInt8((fullLen & 7) << 5 + 0x1f)
            start[6] = 0xfc
        }
        
        return data
    }
    
    func prepareConverter(for sampleBuffer:CMSampleBuffer) {
        
        guard
            let bufferFormatDesc = CMSampleBufferGetFormatDescription(sampleBuffer),
            //获取采样到的数据的格式描述
            let inAudioStreamBasicDesc = CMAudioFormatDescriptionGetStreamBasicDescription(bufferFormatDesc)
        else {
            debugPrint("prepareConverter failed")
            return
        }
        
        var outAudioStreamBasicDesc = AudioStreamBasicDescription()
        // 音频流，在正常播放情况下的帧率。如果是压缩的格式，这个属性表示解压缩后的帧率。帧率不能为0。
        outAudioStreamBasicDesc.mSampleRate = inAudioStreamBasicDesc.pointee.mSampleRate
        // 设置编码格式
        outAudioStreamBasicDesc.mFormatID = kAudioFormatMPEG4AAC
        // 无损编码 ，0表示没有
        outAudioStreamBasicDesc.mFormatFlags = AudioFormatFlags(MPEG4ObjectID.AAC_LC.rawValue)
        //每一个packet的音频数据大小。如果的动态大小，设置为0。动态大小的格式，需要用AudioStreamPacketDescription 来确定每个packet的大小。
        outAudioStreamBasicDesc.mBytesPerPacket = 0
        //每个packet的帧数。如果是未压缩的音频数据，值是1。动态帧率格式，这个值是一个较大的固定数字，比如说AAC的1024。如果是动态大小帧数（比如Ogg格式）设置为0。
        outAudioStreamBasicDesc.mFramesPerPacket = 1024
        //每帧的大小。每一帧的起始点到下一帧的起始点。如果是压缩格式，设置为0 。
        outAudioStreamBasicDesc.mBytesPerFrame = 0
        //声道数
        outAudioStreamBasicDesc.mChannelsPerFrame = 1
        // 压缩格式设置为0
        outAudioStreamBasicDesc.mBitsPerChannel = 0
        // 8字节对齐，填0.
        outAudioStreamBasicDesc.mReserved = 0
        
        guard
            var description = getAudioClassDesc(kAudioFormatMPEG4AAC) else {
                debugPrint("getAudioClassDesc failed")
                return
            }
        
        guard
            AudioConverterNewSpecific(inAudioStreamBasicDesc, &outAudioStreamBasicDesc, 1, &description, &audioConverter) == noErr ,
            audioConverter != nil else {
                debugPrint("AudioConverterNewSpecific failed")
                return
            }
    }
    
    /// 获取编解码器
    /// - Parameters:
    ///   - type: 编码格式
    ///   - fromManufacturer: 软/硬编
    /// - Returns: 编解码器
    func getAudioClassDesc(
        _ type:UInt32,
        _ fromManufacturer:UInt32 = kAppleSoftwareAudioCodecManufacturer) -> AudioClassDescription?
    {
        var encoderSepecifier = type
        
        var size:UInt32 = 0
        guard
            AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders, UInt32(MemoryLayout.stride(ofValue: encoderSepecifier)), &encoderSepecifier, &size) == noErr
        else {
            debugPrint("AudioFormatGetPropertyInfo failed.")
            return nil
        }
        let count = Int(size) / MemoryLayout<AudioClassDescription>.stride
        let descriptions = UnsafeMutablePointer<AudioClassDescription>.allocate(capacity: count)
        defer {
            descriptions.deinitialize(count: count)
            descriptions.deallocate()
        }
        guard
            AudioFormatGetProperty(
                kAudioFormatProperty_Encoders,
                UInt32(MemoryLayout.stride(ofValue: encoderSepecifier)),
                &encoderSepecifier ,
                &size,
                descriptions) == noErr else {
                    debugPrint("AudioFormatGetProperty failed")
                    return nil
                }
        for i in 0..<count {
            if type == descriptions[i].mSubType &&
                fromManufacturer == descriptions[i].mManufacturer {
                var result = AudioClassDescription()
                result.mSubType = descriptions[i].mSubType
                result.mManufacturer = descriptions[i].mManufacturer
                result.mType = descriptions[i].mType
                return result
            }
        }
        return nil
    }
}


