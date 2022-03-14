//
//  CustomResourceLoader.swift
//  AVFoundationDemo
//
//  Created by apple on 2022/1/4.
//

import Foundation
import AVFoundation
import CoreServices
import UIKit


//MARK: - Define
 class AssetResourceLoaderDelegate:NSObject {
    
    let videoDownLoader:AssertDownloader
    let assertURL:URL
    
    init(asserURL:URL, videoDownLoader:AssertDownloader) {
        self.assertURL = asserURL
        self.videoDownLoader = videoDownLoader
        super.init()
        self.installActionsForVideoDownloader()
    }
    
    var customScheme:String = "CustomAssetResourceLoaderDelegate"
    
    lazy private
    var requestContextTable = [AssetDownloadingTaskContext]()
    
    lazy private(set) var isFirstRequest:Bool = false
    
    lazy private(set)
     var videoFileManager:VideoCacheFileManager = {
         let result = VideoCacheFileManager.init(key: assertURL.absoluteString)
         _ = result.createCacheFileIfNotExist()
         try? result.loadIndexFileInfo()
         isFirstRequest = result.getFileFullLength() == nil
         return result
     }()
    
    lazy private var workQueue = DispatchQueue.init(label: "CustomAssetResourceLoaderDelegate.workQueue")
}

//MARK: - SubTypes
extension AssetResourceLoaderDelegate {
   fileprivate class AssetDownloadingTaskContext {
       
        let loadingRequest:AVAssetResourceLoadingRequest
        let sessionTask:URLSessionTask
        
        lazy fileprivate(set) var writeOffset:UInt64 = 0
        
        init(loadingRequest:AVAssetResourceLoadingRequest,sessionTask:URLSessionTask) {
            self.loadingRequest = loadingRequest
            self.sessionTask = sessionTask
        }
    }
}

//MARK: - Notification
extension AssetResourceLoaderDelegate {
    
   static var cachedRangeChanged:Notification.Name {
        return .init(rawValue: "AssetResourceLoaderDelegate.Notification.loadedCachedRange")
    }
    
    

}


//MARK: - Override
extension AssetResourceLoaderDelegate:AVAssetResourceLoaderDelegate {
    
    //MARK:  Processing Resource Request
    
    ///Asks the delegate if it wants to load the requested resource.
    ///如果返回false, 要调用 AVAssetResourceLoadingRequestd的finish方法通知系统
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        debugPrint(#function)
 
        NotificationCenter.default.post(name: AssetResourceLoaderDelegate.cachedRangeChanged, object: self)
        
        workQueue.async {
            //self.startFullNetworkLoad(for: loadingRequest)
            //self.startFullLocalLoad(for: loadingRequest)

            if self.isFirstRequest {
                self.startFullNetworkLoad(for: loadingRequest)
            } else  {
                self.startLoad(for: loadingRequest)
            }

        }
        
        return true
    }
    
    ///Informs the delegate that a prior loading request has been cancelled.
        func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
            debugPrint(#function)
           let canceled = requestContextTable.filter({
                $0.loadingRequest === loadingRequest
            })
            canceled.forEach({
                [weak self]  v in
                v.sessionTask.cancel()
                if let index = requestContextTable.firstIndex(where: {
                    $0.loadingRequest === loadingRequest
                }) {
                    self?.requestContextTable.remove(at: index)
                }
            })
        }
}


//MARK: - Interface
extension AssetResourceLoaderDelegate {
    
    var handledUrl:URL {
        guard var urlcom = URLComponents.init(url: assertURL, resolvingAgainstBaseURL: true) else {
            return assertURL
        }
        urlcom.scheme = customScheme
        return urlcom.url ?? assertURL
    }
    
}

//MARK: - Private
private extension AssetResourceLoaderDelegate {
    //MARK: 全部请求
    func startFullNetworkLoad(for loadingRequest:AVAssetResourceLoadingRequest) {
        guard let dataRequest = loadingRequest.dataRequest else {
            return
        }
        let videoReuest = dataRequest.createVideoRequest(for: assertURL)
        
        let task = videoDownLoader.startDownload(
            for: videoReuest,
               resumeImmediately: false,
               joinIntermediateData: false)
        
        let shoudStartRequest = requestContextTable.count == 0
        requestContextTable.append(.init(loadingRequest: loadingRequest, sessionTask: task))
        debugPrint("requestContextTable:\(requestContextTable.count)")
        if (shoudStartRequest) {
            //first time,resume task.
            task.resume()
        }
    }
    
    func startFullLocalLoad(for loadingRequest:AVAssetResourceLoadingRequest) {
        guard
            let dataRequest = loadingRequest.dataRequest,
            let loadingRequestURl = loadingRequest.request.url,
            var headers = videoFileManager.getResponseHeaders(),
            let fileSize = videoFileManager.getFileFullLength()
        else {
            debugPrint("本地数据必要条件不满足")
            return
        }
        
        do {
            let (start,end) = dataRequest.bytesRange
            let readEnd = end == nil ? Int64(fileSize) : end!
            guard let data = try videoFileManager.read(offset: UInt64(start), length:Int(readEnd) - Int(start) ) else {
                loadingRequest.finishLoading(with: nil )
                debugPrint("读取文件data为nil")
                return
            }
        
            headers["Content-Length"] = "\(data.count)"
            headers["content-range"] = "bytes \(start)-\(readEnd)/\(fileSize)"
           debugPrint("fl bytes \(start)-\(readEnd)/\(fileSize)")
            
            guard  let response = HTTPURLResponse.init(url: loadingRequestURl, statusCode: 206, httpVersion: "HTTP/1.1", headerFields: headers) else {
                debugPrint("构造httpResponse 失败")
                loadingRequest.finishLoading(with: nil)
                return
            }
            
            loadingRequest.response = response
            loadingRequest.contentInformationRequest?.fillProperties(with: response)
            dataRequest.respond(with: data)
            loadingRequest.finishLoading()
            
        } catch let err {
            loadingRequest.finishLoading(with: err)
            debugPrint("startLocalLoad Error:\(err)")
        }
    }
    
    //MARK: 部分请求
    func startLoad(for loadingRequest:AVAssetResourceLoadingRequest) {
        guard
            let dataRequest = loadingRequest.dataRequest
        else {
            debugPrint("本地数据必要条件不满足")
            return
        }

        var (start,end) = dataRequest.bytesRange
        let readEnd = end == nil ? start + Int64(dataRequest.requestedLength) : end!
        
        debugPrint("startLoad: \(start)-\(end)-\(readEnd)")
        while start < readEnd {
            if let firstNotCachedRange = videoFileManager.firstNotCacheRange(from: UInt(start)) {
                debugPrint("firstNotCachedRange:\(firstNotCachedRange.toBeginEndFormatString())")
                if firstNotCachedRange.location >= readEnd {
                    startLocalLoad(for: loadingRequest, start: start, end: readEnd)
                    start = readEnd
                } else if firstNotCachedRange.location >= start {
                    if (firstNotCachedRange.location > start) {
                        startLocalLoad(for: loadingRequest, start: start, end: Int64(firstNotCachedRange.location) - start)
                    }
                    let notCachedEnd = min(NSMaxRange(firstNotCachedRange),Int(readEnd))
                    startNetworkLoad(for: loadingRequest, start: Int64(firstNotCachedRange.location), end: Int64(notCachedEnd))
                    start = Int64(notCachedEnd)
                } else {
                    startLocalLoad(for: loadingRequest, start: start, end: readEnd)
                    start = readEnd
                }
            } else {
                if videoFileManager.isFullCached {
                    startLocalLoad(for: loadingRequest, start: start, end: readEnd)
                } else {
                    startNetworkLoad(for: loadingRequest, start: start, end: readEnd)
                }
                start = readEnd
            }
        }
    }
    
    func startLocalLoad(for loadingRequest:AVAssetResourceLoadingRequest,start:Int64,end:Int64?) {
        guard
            let dataRequest = loadingRequest.dataRequest,
            let loadingRequestURl = loadingRequest.request.url,
            var headers = videoFileManager.getResponseHeaders(),
            let fileSize = videoFileManager.getFileFullLength()
        else {
            debugPrint("本地数据必要条件不满足")
            return
        }
        
        do {
            let readEnd = end == nil ? Int64(fileSize) : end!
            guard let data = try videoFileManager.read(offset: UInt64(start), length:Int(readEnd) - Int(start) + 1) else {
                loadingRequest.finishLoading(with: nil )
                debugPrint("读取文件data为nil")
                return
            }
        
            headers["Content-Length"] = "\(data.count)"
            headers["content-range"] = "bytes \(start)-\(readEnd)/\(fileSize)"
            
            debugPrint("ll bytes \(start)-\(readEnd)/\(fileSize)")
           
            guard  let response = HTTPURLResponse.init(url: loadingRequestURl, statusCode: 206, httpVersion: "HTTP/1.1", headerFields: headers) else {
                debugPrint("构造httpResponse 失败")
                loadingRequest.finishLoading(with: nil)
                return
            }
            
            loadingRequest.response = response
            loadingRequest.contentInformationRequest?.fillProperties(with: response)
            dataRequest.respond(with: data)
            loadingRequest.finishLoading()
            try? videoFileManager.synchronousStoredIndexValuesToIndexFile()
            
        } catch let err {
            loadingRequest.finishLoading(with: err)
            debugPrint("startLocalLoad Error:\(err)")
        }

    }
    
    
    
    
    func startNetworkLoad(for loadingRequest:AVAssetResourceLoadingRequest,start:Int64 ,end:Int64) {
       
        var videoRequest = URLRequest.init(url: assertURL)
        videoRequest.httpShouldUsePipelining = true
        videoRequest.cachePolicy = .reloadIgnoringLocalCacheData
        let bytesStr:String = "bytes=\(start)-\(end)"
        debugPrint("bytes=\(start)-\(end)")
       
        videoRequest.setValue(bytesStr, forHTTPHeaderField: "Range")
        debugPrint("startNetworkLoad createVideoRequest:\(bytesStr)")
        
        let task = videoDownLoader.startDownload(
            for: videoRequest,
               resumeImmediately: false,
               joinIntermediateData: false)
        
        let shoudStartRequest = requestContextTable.count == 0
        requestContextTable.append(.init(loadingRequest: loadingRequest, sessionTask: task))
        if (shoudStartRequest) {
            //first time,resume task.
            task.resume()
        }
    }
    
    
   
    //MARK: 网络加载任务相关
    func queryContextUsing(sessionTaskId:Int) -> AssetDownloadingTaskContext? {
        return requestContextTable.first(where: {
            $0.sessionTask.taskIdentifier == sessionTaskId
        })
    }
    
    func deleteContextUsing(sessionTaskId:Int) {
       if let index = requestContextTable.firstIndex(where: {
            $0.sessionTask.taskIdentifier == sessionTaskId
       }) {
           requestContextTable.remove(at: index)
       }
    }
    
    //MARK: 注册VideoDownLoader事件回调
    func installActionsForVideoDownloader() {
        
        videoDownLoader.didReceiveResponse = {
            [weak self]
            (_ task: URLSessionTask, _ response: URLResponse) in
           // debugPrint("didRecieveResponse",response)
            self?.workQueue.async {
                if let c = self,
                   let loadingRequest = c.queryContextUsing(sessionTaskId: task.taskIdentifier)?.loadingRequest,
                   let contentInfoRequest = loadingRequest.contentInformationRequest,
                   let httpResponse = response as? HTTPURLResponse
                {
                    loadingRequest.response = response
                    contentInfoRequest.fillProperties(with: httpResponse)
                    
                    //保存文件总长度
                    c.videoFileManager.setFileFullLength(UInt64(httpResponse.rangeContentLength))
                    
                    c.videoFileManager.setResponseHeaders(for: httpResponse)
                }
            }
           
        }
        
        videoDownLoader.didRecieveData = {
           [weak self]
           (_ task: URLSessionTask, _ data:Data) in
            //debugPrint("didRecieveData",data.count)
            self?.workQueue.async {
                if let c = self,
                   let ctx =  c.queryContextUsing(sessionTaskId: task.taskIdentifier)
                  {
                    let loadingRequest = ctx.loadingRequest
                    loadingRequest.dataRequest?.respond(with: data)
                   
                    if
                        let start = loadingRequest.dataRequest?.bytesRange.start
                    {
                      
                        do {
                            if ctx.writeOffset == 0 {
                                ctx.writeOffset = UInt64(start)
                            }
                          
                           try c.videoFileManager.write(data: data, offset: UInt64(ctx.writeOffset))
                            let range = NSRange(location: Int(ctx.writeOffset), length: data.count)
                            //保存已经写入的文件范围
                            c.videoFileManager.appendCachedRange(range)
                            
                            //增加以写入长度
                            c.videoFileManager.appendWritedLength(UInt64(data.count))
                            
                            NotificationCenter.default.post(name: AssetResourceLoaderDelegate.cachedRangeChanged, object: c)
                            
                            //debugPrint("-->\(range.toBeginEndFormatString()),")
                            ctx.writeOffset = UInt64(NSMaxRange(range))

                        } catch let err {
                            debugPrint("write err:\(err)")
                        }
                    }
                }
            }
        }
        
        videoDownLoader.didComplete = {
            [weak self]
            (_ taskContext:AssertDownloader.TaskContext, _ error:Error?) in
            debugPrint("didComplete")
            self?.workQueue.async {
                if let c = self,
                   let loadingRequest = c.queryContextUsing(sessionTaskId: taskContext.task.taskIdentifier)?.loadingRequest {
                    if let e = error {
                        loadingRequest.finishLoading(with: e)
                    } else {
                        loadingRequest.finishLoading()
                    }
                    
                    do {
                        //同步信息到文件中
                        try c.videoFileManager.synchronousStoredIndexValuesToIndexFile()
                    } catch let err {
                        debugPrint("sync error:\(err)")
                    }
                    
                    c.deleteContextUsing(sessionTaskId: taskContext.task.taskIdentifier)
                    //继续其它没有开始的任务
                    c.requestContextTable.first?.sessionTask.resume()
                }
            }
            
        }
    }
}
