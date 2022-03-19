//
//  TAG.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/10/26.
//

import Foundation

//!!!: 这里会有内存对齐,导致数据不能与二进制对齐,进而数据错误
///目前不知道swift如何禁用内存对齐, 目前想到的解决方法是使用 c struct加   __attribute__ ( ( packed ) ) 禁用内存对齐(紧凑模式),然后使用OC对象包装,再用swift调用 ╮(╯▽╰)╭


struct TGA {
    
    static func loadTGA(fileName:String) -> (Data?,Int32,Int32) {
        guard
           let fp = fileOpen(fileName: fileName)
        else {
            debugPrint("\(fileName) open fail.")
            return (nil,0,0)
        }
        defer { _ = fileClose(fp: fp) }
        ///读取tag文件头部
        let headerBytes = MemoryLayout<TgaHeader>.stride 
        var buffer = UnsafeMutableRawPointer.allocate(byteCount: headerBytes, alignment: MemoryLayout<CChar>.alignment)
        _  = fileRead(fp: fp, bytesToRead: headerBytes,outBuffer: &buffer)
        
        
        defer { buffer.deallocate() }
        
        let  tagHeader = buffer.bindMemory(to: TgaHeader.self, capacity: 1).pointee
        
        let width = tagHeader.width
        let height = tagHeader.height
        
        if tagHeader.colorDepth == 8 || tagHeader.colorDepth == 24 || tagHeader.colorDepth == 32 {
            let bytesToRead = MemoryLayout<UInt8>.stride * Int(width) * Int(height) * Int(tagHeader.colorDepth) / 8
            
            var dataBuffter = UnsafeMutableRawPointer.allocate(byteCount: bytesToRead, alignment: MemoryLayout<Int8>.alignment)
            defer { dataBuffter.deallocate() }
            
            _ = fileRead(fp: fp, bytesToRead: bytesToRead, outBuffer: &dataBuffter)
            
            return (Data.init(bytes: dataBuffter, count: bytesToRead),Int32(width),Int32(height))
            
        }
       return  (nil,0,0)
    }
    
   static func fileOpen(fileName:String) ->  UnsafeMutablePointer<FILE>? {
       let baseName = (fileName as NSString).deletingPathExtension
       let ext = (fileName as NSString).pathExtension
       guard
        let path = Bundle.main.path(forResource: baseName, ofType: ext)
       else { return nil }
        
        var pFile: UnsafeMutablePointer<FILE>? = nil
        path.withCString { pointer1 in
            "rb".withCString { pointer2 in
                pFile = fopen(pointer1, pointer2)
            }
        }
        return pFile
    }
    
    static func fileClose(fp:UnsafeMutablePointer<FILE>) -> Int32 {
        return fclose(fp)
    }
    
    static func fileRead(fp: UnsafeMutablePointer<FILE>,bytesToRead: Int, outBuffer:inout UnsafeMutableRawPointer) -> Int {
        let bytesRead = fread(outBuffer, bytesToRead, 1, fp)
       return bytesRead
    }
}
