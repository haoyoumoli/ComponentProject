//
//  AssertDownloader.swift
//  AVFoundationDemo
//
//  Created by apple on 2022/1/12.
//

import Foundation

//MARK: - Define
class AssertDownloader: NSObject {
    
    static var defaultDownloader: AssertDownloader {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return AssertDownloader.init(sessionConfig: config)
    }
    
    lazy private(set)
    var session: URLSession! = nil
    
    init(sessionConfig:URLSessionConfiguration) {
        super.init()
        self.session = URLSession.init(configuration: sessionConfig, delegate: self, delegateQueue: nil)
    }
    
    deinit {
        for (_,v) in taskTable {
            v.task.cancel()
        }
    }
    
    
    lazy private
    var taskTable = [Int:TaskContext]()
    
    ///执行HTTP重定向的回调,AssertDownloader总是跟随重定向
    var willPerformHTTPRedirection:((_ task: URLSessionTask,_ response: HTTPURLResponse,_ newRequest: URLRequest) -> Void)?
    
    ///收到了请求的响应部分
    var didReceiveResponse:((_ task: URLSessionTask, _ response: URLResponse) -> Void)? = nil
    
    ///接受到了数据 AssertDownloader 默认会讲接受到每一段数据整合到一起
    ///在完成时放到TaskContext中
    var didRecieveData:((_ task: URLSessionTask, _ data:Data) -> Void)? = nil
    
    // 某一个任务已经完成
    var didComplete:((_ taskContext:AssertDownloader.TaskContext, _ error:Error?) -> Void)? = nil
   
}

//MARK: - Interface
extension AssertDownloader {
    
    /// 创建请求任务
    /// - Parameters:
    ///   - request: 请求
    ///   - resumeImmediately: 是否立即开始请求
    ///   - joinIntermediateDate: 是否负责拼接中间数据, 如果设置了这个值为false , 务必设置didRecieveData
    ///   在完成是TaskContext的 joinIntermediateDateByUser 为true, data.count = 0
    /// - Returns: 请求任务
    func startDownload(for request:URLRequest,
                       resumeImmediately:Bool,
                       joinIntermediateData: Bool = true
    ) -> URLSessionDataTask {
        let task = session.dataTask(with: request)
        task.resume()
        var tastCtx = TaskContext(task: task)
        tastCtx.joinIntermediateDataUser = !joinIntermediateData
        taskTable[task.taskIdentifier] = tastCtx
        return task
    }
}

//MARK: - URLSessionDataTask

extension AssertDownloader: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        willPerformHTTPRedirection?(task,response,request)
        completionHandler(request)
    }
    
//    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        var disposition:URLSession.AuthChallengeDisposition = .performDefaultHandling
//        var credential:URLCredential? = nil
//        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
//           let serverTrust = challenge.protectionSpace.serverTrust {
//            credential = URLCredential.init(trust: serverTrust)
//            disposition = .useCredential
//        }
//        completionHandler(disposition,credential)
//    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        didReceiveResponse?(dataTask,response)
        taskTable[dataTask.taskIdentifier]?.response = response
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        didRecieveData?(dataTask,data)
         if var ctx = taskTable[dataTask.taskIdentifier],
            ctx.joinIntermediateDataUser == false {
            ctx.data.append(data)
            taskTable[dataTask.taskIdentifier] = ctx
         }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer { taskTable[task.taskIdentifier] = nil }
        if let ctx = taskTable[task.taskIdentifier]
        {
            if ctx.joinIntermediateDataUser == false,
            ( ctx.data.count) != task.countOfBytesReceived
            {   didComplete?(ctx,Self.getDataLenghtNotEqualError(underlyError: error))
               return
            }
            didComplete?(ctx,error)
        }
    }
    
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
//        completionHandler(nil)
//    }
}


//MARK: - SubTypes
extension AssertDownloader {
    struct TaskContext {
        let task:URLSessionTask
        init(task:URLSessionTask) {
            self.task = task
        }
        fileprivate(set) var joinIntermediateDataUser = false
        fileprivate(set) var data:Data = Data()
        fileprivate(set) var response:URLResponse? = nil
        
    }
}

//MARK: - Private

//MARK: Error
private extension AssertDownloader {
     static var errorDomain:String {
        return "AssertDownloader.error.domain"
    }
    
    static func getDataLenghtNotEqualError(underlyError:Error?) -> NSError {
        return NSError.init(domain: errorDomain, code: 1, userInfo: [
            NSLocalizedFailureReasonErrorKey:"数据长度与任务期待不相同",
            NSUnderlyingErrorKey:underlyError as Any
        ])
    }
}

