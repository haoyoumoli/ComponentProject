//
//  Extensions.swift
//  AVFoundationDemo
//
//  Created by apple on 2022/1/12.
//

import Foundation
import CoreServices
import AVFoundation
import CommonCrypto

//MARK:  - HTTPURLResponse
extension HTTPURLResponse {
    var contentType:String? {
        guard
            let mimeType = self.mimeType,
            let contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil) else {
            return nil
        }
        return contentType.takeRetainedValue() as String
    }
    
    
    var isSupportRange: Bool {
        return self.contentRange != nil
    }
    
    var rangeContentLength: Int64 {
        if
            let contentRange = self.contentRange,
            let separaIndex = contentRange.lastIndex(of: "/")
        {
            let startIndex = contentRange.index(separaIndex, offsetBy: 1)
            if  contentRange.indices.contains(startIndex) {
                let lengthString = contentRange[startIndex..<contentRange.endIndex]
                if let lenght = Int64(lengthString) {
                    return lenght
                }
            }
        }
        return expectedContentLength
        
    }
    
    var contentRange:String? {
        if let s = allHeaderFields["content-range"] as? String  {
            return s
        }
        if let s = allHeaderFields["Content-Range"] as? String {
            return s
        }
        
        if let s = allHeaderFields["Content-range"] as? String {
            return s
        }
        
        if let s = allHeaderFields["content-Range"] as? String {
            return s
        }
        return nil
    }
    
}


//MARK: - AVAssetResourceLoadingDataRequest
extension  AVAssetResourceLoadingDataRequest {
    
    func createVideoRequest(for url:URL) -> URLRequest {
        var videoRequest = URLRequest.init(url: url)
        videoRequest.httpShouldUsePipelining = true
        videoRequest.cachePolicy = .reloadIgnoringLocalCacheData
        var bytesStr:String
        let (start,end) = bytesRange
        if end == nil {
            bytesStr = "bytes=\(start)-"
        } else {
            bytesStr = "bytes=\(start)-\(end!)"
        }
        videoRequest.setValue(bytesStr, forHTTPHeaderField: "Range")
        debugPrint("createVideoRequest:\(bytesStr)")
        return videoRequest
    }
    
    /// 获取请求数据的范围, nil表示到最后
    var bytesRange:(start:Int64,end:Int64?) {
        var start:Int64 = 0
        var end:Int64? = nil
       
        //最开始的请求
        if requestsAllDataToEndOfResource {
            start = requestedOffset
        } else {
            //最开始的请求
            if requestedOffset == 0 {
                start = currentOffset
                end = currentOffset + Int64(requestedLength - 1)
            } else {
                start = requestedOffset
                end = requestedOffset + Int64(requestedLength - 1)
            }
        }
        return (start,end)
    }
}


//MARK: - AVAssetResourceLoadingContentInformationRequest
extension AVAssetResourceLoadingContentInformationRequest {
    func fillProperties(with httpResponse:HTTPURLResponse) {
        self.contentType = httpResponse.contentType
        self.isByteRangeAccessSupported = httpResponse.isSupportRange
        self.contentLength = httpResponse.rangeContentLength
    }
}

//MARK: - NSRange

extension NSRange {
    
   static func createWith(beginEndFormatStr:String) -> NSRange? {
       let strArr = beginEndFormatStr.components(separatedBy: "-")
       guard
        strArr.count == 2,
        let beginValue = Int(strArr.first!),
        let endValue = Int(strArr.last!) else {
            return nil
        }
      return NSMakeRange(beginValue, endValue - beginValue)
    }
    
    func toBeginEndFormatString() -> String {
        return "\(location)-\(location + length)"
    }
    
    static func canMerge(r1:NSRange,r2:NSRange) -> Bool {
        return (NSMaxRange(r1) == r2.location) || (NSMaxRange(r2) == r1.location) || (r1.intersection(r2) != nil) || (r2.intersection(r1) != nil)
    }
}

//MARK: - String
 extension String {
    var md5:String {
        let cStr = self.cString(using: .utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: .utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(cStr!, strLen, result)
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deallocate()
        return hash as String
    }
}

