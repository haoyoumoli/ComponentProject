//
//  VideoCacheFileManager.swift
//  AVFoundationDemo
//
//  Created by apple on 2022/1/13.
//

import Foundation

//MARK: - Define
class VideoCacheFileManager {
    
    let filePath:String
    
    let indexFilePath:String
    
    
    convenience init(key:String)  {
        //        let cachePaths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        //        let cachePath = cachePaths.first!
        let cachePath = "/Users/apple/Desktop"
        let dirPath = "\(cachePath)/VideoCacheFileManager"
        let fm = FileManager.default
        if fm.fileExists(atPath: dirPath) == false {
            try? fm.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
        }
        self.init(key:key,path:dirPath)
    }
    
    init(key:String,path:String) {
        let fileName = key.md5
        self.filePath = "\(path)/\(fileName)"
        self.indexFilePath =  "\(path)/\(fileName).json"
    }
    
    lazy private(set)
    var writeFileHanlder:FileHandle? = .init(forWritingAtPath: filePath)
    
    lazy private(set)
    var readFileHandler:FileHandle? = .init(forReadingAtPath: filePath)
    
    
    lazy private(set)
    var indexInfoDic: [String:Any]? = nil
}

//MARK: - SubTypes
extension VideoCacheFileManager {
    enum WriteError:Error {
        case writeFileHanlderIsNil
        case otherError(underingError:Error)
    }
    
    enum ReadError:Error {
        case readFileHanlderIsNil
        case otherError(underingError:Error)
    }
    
    struct IndexFileKey {
        static var responseHeader: String {
            return "index.file.http.response.header"
        }
        
        static var cachedByteRanges: String {
            return "index.file.cached.byte.ranges"
        }
        
        static var fullLenght:String {
            return "index.file.full.length"
        }
        
        static var writedFileLength:String {
            return "index.file.writed.length"
        }
    }
    
    
}

//MARK: - Override
extension VideoCacheFileManager {}

//MARK: - Interface
///缓存文件操作
extension VideoCacheFileManager {
    
    ///在提供缓存文件目录创建缓存文件, 文件存在的返回成功, 文件不存在的返回失败
    func createCacheFileIfNotExist() -> Bool {
        if FileManager.default.fileExists(atPath: filePath) {
            return true
        }
        if FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)  {
            return true
        }
        return false
    }
    
    /// 向filePath中写入内容
    /// - Parameters:
    ///   - data: 数据
    ///   - offset: 偏移量
    /// - throw  WriteError
    func write(data:Data,offset:UInt64) throws {
        guard let wf = self.writeFileHanlder else {
            throw WriteError.writeFileHanlderIsNil
        }
        do {
            try wf.seek(toOffset: offset)
            if #available(iOS 13.4, *) {
                try wf.write(contentsOf: data)
            } else {
                wf.write(data)
            }
        } catch let err {
            throw WriteError.otherError(underingError: err)
        }
    }
    
    
    /// 读取数据
    /// - Parameters:
    ///   - offset: 指定偏移量
    ///   - length: 长度
    /// - Returns: 返回得到输入
    /// - 如果失败抛出ReadError
    func read(offset:UInt64,length:Int) throws -> Data?  {
        guard let rf = readFileHandler else {
            throw ReadError.readFileHanlderIsNil
        }
        do {
            try rf.seek(toOffset: offset)
            if #available(iOS 13.4, *) {
                let data = try rf.read(upToCount: length)
                return data
            } else {
                let data = rf.readData(ofLength: length)
                return data
            }
        } catch let err {
            throw ReadError.otherError(underingError: err)
        }
    }
}

///缓存索引文件操作
///因为文件的写入是可能会有空洞的,索引文件记录有效的文件范围和响应信息
extension VideoCacheFileManager {
    
    var isFullCached:Bool {
        guard
            let infoDic = indexInfoDic,
            let bytesStringRanges = infoDic[IndexFileKey.cachedByteRanges] as? [String],
            let fullFileSize = getFileFullLength()
        else {
            return false
        }
        
        let bytesRanges = bytesStringRanges.compactMap({
            return NSRange.createWith(beginEndFormatStr:$0)
        })
        guard bytesRanges.count == 1 else {
            return false
        }
        
        return NSMaxRange(bytesRanges.first!) == fullFileSize
    }
    
    func loadIndexFileInfo() throws {
        let url = URL(fileURLWithPath: indexFilePath)
        let data = try? Data.init(contentsOf: url)
        if data == nil {
            self.indexInfoDic = [String:Any]()
        } else {
            let infoDics = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
            self.indexInfoDic = infoDics
        }
        mergeContentBytesRangesIfNeeded()
    }
    
    
    func synchronousStoredIndexValuesToIndexFile() throws {
        guard indexInfoDic != nil else {
            return
        }
        let data = try JSONSerialization.data(withJSONObject: indexInfoDic!, options: [])
        let url = URL(fileURLWithPath: indexFilePath)
        try data.write(to: url)
    }
    
    
    func setResponseHeaders(for response:HTTPURLResponse) {
        guard indexInfoDic != nil else {
            return
        }
        indexInfoDic![IndexFileKey.responseHeader] = response.allHeaderFields
    }
    
    func getResponseHeaders() -> [String:String]? {
        guard indexInfoDic != nil else {
            return nil
        }
        return indexInfoDic![IndexFileKey.responseHeader] as? [String:String]
    }
    
    
    func firstNotCacheRange(from position:UInt) -> NSRange? {
        guard indexInfoDic != nil,
              let cachedStringRanges = indexInfoDic![IndexFileKey.cachedByteRanges] as? [String],
              let fileFullSize = getFileFullLength()
        else {
            return nil
        }
        
        let cachedRanges = cachedStringRanges.compactMap({
            return NSRange.createWith(beginEndFormatStr: $0)})
        if position >= fileFullSize {
            return nil
        }
        var targetRange:NSRange? = nil
        var index = 0
        var start = position
        while index < cachedRanges.count {
            defer { index += 1}
            let range = cachedRanges[index]
            if NSLocationInRange(Int(position), range) {
                start = UInt(NSMaxRange(range))
            } else {
                if (start >= NSMaxRange(range)) {
                    continue;
                } else {
                    targetRange = NSMakeRange(Int(start), range.location - Int(start))
                }
            }
        }
        if (start < fileFullSize) {
            targetRange = NSMakeRange(Int(start), Int(fileFullSize) - Int(start))
        }
        
        return targetRange
    }
    
    
    
    func appendCachedRange(_ range:NSRange) {
        guard indexInfoDic != nil else {
            return
        }
        var cachedRanges:[String]
        if let v = indexInfoDic![IndexFileKey.cachedByteRanges] as? [String] {
            cachedRanges = v
        } else {
            cachedRanges = []
        }
        cachedRanges.append(range.toBeginEndFormatString())
        indexInfoDic![IndexFileKey.cachedByteRanges] = cachedRanges
        mergeContentBytesRangesIfNeeded()
        
        //debugPrint("-->",cachedRanges)
    }
    
    func appendWritedLength(_ writedLength:UInt64) {
        guard indexInfoDic != nil else {
            return
        }
        var result:UInt64
        if let v = indexInfoDic![IndexFileKey.writedFileLength] as? UInt64 {
            result = v
        } else {
            result = 0
        }
        result += writedLength
        indexInfoDic![IndexFileKey.writedFileLength] = result
        
    }
    
    func setFileFullLength(_ fullLength:UInt64) {
        guard indexInfoDic != nil else {
            return
        }
        indexInfoDic![IndexFileKey.fullLenght] = fullLength
    }
    
    func getFileFullLength() -> UInt64? {
        guard indexInfoDic != nil else {
            return nil
        }
        return indexInfoDic![IndexFileKey.fullLenght] as? UInt64
    }
    
}

//MARK: - Private

private extension VideoCacheFileManager {
    
    func mergeContentBytesRangesIfNeeded() {
        if indexInfoDic == nil  {
            return
        }
        guard
            let bytesStringRanges = indexInfoDic![IndexFileKey.cachedByteRanges] as? [String] else {
                return
            }
        
        var bytesRanges = bytesStringRanges.compactMap({
            return NSRange.createWith(beginEndFormatStr:$0)
        }).sorted(by: { $0.location < $1.location })
        
        var index = 0
        while index + 1 < bytesRanges.count {
            let before = bytesRanges[index]
            let after = bytesRanges[index + 1]
            if NSRange.canMerge(r1: before, r2: after) {
                bytesRanges[index] = NSUnionRange(before, after)
                bytesRanges.remove(at: index + 1)
            } else {
                index += 1
            }
            
        }
        indexInfoDic![IndexFileKey.cachedByteRanges] = bytesRanges.map({ $0.toBeginEndFormatString() })
        
    }
    
}

///自己写的无用算法
extension VideoCacheFileManager {
    struct RangesInfo {
        let cached:Bool
        let range:NSRange
        
        init(cached:Bool,range:NSRange) {
            self.cached = cached
            self.range = range
        }
    }
    
    func getRangesInfo3For(start:Int , end:Int) -> [RangesInfo] {
        guard start <= end else {
            return []
        }
        
        guard
            indexInfoDic != nil,
            let cachedStringRanges = indexInfoDic![IndexFileKey.cachedByteRanges] as? [String] else {
                return []
            }
        
        let cachedRanges = cachedStringRanges.compactMap({
            return NSRange.createWith(beginEndFormatStr: $0)})
        
        var start = start
        var index = 0
        var result = [RangesInfo]()
        while start < end  && index < cachedRanges.count {
            defer { index += 1}
            let curRange = cachedRanges[index]
            
            let locationGreateStart = curRange.location >= start
            
            let startInCurRange = NSLocationInRange(start, curRange)
            
            if startInCurRange {
                result.append(.init(cached: true, range: NSMakeRange(start,NSMaxRange(curRange) - start)))
                start = NSMaxRange(curRange)
                
            } else if locationGreateStart {
                result.append(.init(cached: false, range: NSMakeRange(start, curRange.location - start)))
                start = curRange.location
                let maxRangeLessEnd = NSMaxRange(curRange) <= end
                let endInCurRange = NSLocationInRange(end, curRange)
                if endInCurRange {
                    result.append(.init(cached: true, range: NSMakeRange(curRange.location, end - curRange.location)))
                    start = end
                } else if maxRangeLessEnd {
                    result.append(.init(cached: true, range: curRange))
                    start = NSMaxRange(curRange)
                }
            }
        }
        
        if  start < end,
            let lastRange = result.last?.range,
            NSMaxRange(lastRange) < end
        {
            result.append(.init(cached: false, range: NSMakeRange(NSMaxRange(lastRange), end - NSMaxRange(lastRange))))
        }
        
        return result
    }
}
