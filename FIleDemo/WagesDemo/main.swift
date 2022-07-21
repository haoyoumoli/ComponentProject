//
//  main.swift
//  WagesDemo
//
//  Created by apple on 2021/8/3.
//

import Foundation


Algorithm().start()


extension String {
    func getSubString(at location:Int,length:Int) -> String? {
        if location < 0 ||
            (location + length) >= self.count {
            return nil
        }

        let begin = self.index(self.startIndex, offsetBy: location)
        let end = self.index(begin, offsetBy: length)
        return String(self[begin..<end])
    }

    func getSubString(at range:NSRange) -> String? {
        return getSubString(at: range.location, length: range.length)
    }

    func match(regex:NSRegularExpression,mathOptions:NSRegularExpression.MatchingOptions = []) -> [(String,NSTextCheckingResult)] {
        let result = regex.matches(in: self,options: mathOptions,
                                    range: NSRange(location: 0, length: self.count) )
        let retArr:[(String,NSTextCheckingResult)] = result.reduce([]) { rs, ele in
            var rs = rs
            if let sub = self.getSubString(at: ele.range) {
                rs.append((sub,ele))
            }
            return rs
        }

        return retArr

    }
}

func stringMatchTest() {
    let text = """
            Runoob,runoob,runOOb
            And set the queuePriority. Here the @synchronized (operation) is used to compare the @synchronized (self), which is used inside the operation to ensure the thread safety of the operation between two different classes. Because the operation may be passed to the decoding or proxy queue.

            Then addHandlersForProgres method will save progressBlock and completedBlock into NSMutableDictionary <NSString *, id> SDCallbacksDictionary and then return and save it into downloadOperationCancelToken.

            In addition, operation in addHandlersForProgress method does not clear the previous stored callbacks. They are saved incrementally, which means that all the callBacks will be executed in sequence after download completion.

            If the operation is nil、isFinished or isCancelled will call createDownloaderOperationWithUrl:options:context: to create a new operation and store it in URLOperations and configure completionBlock. So that URLOperations can be cleared when the task is completed. Then call addHandlersForProgress:completed: to save progressBlock and completedBlock. At last submit operation to the downloadQueue.

            The final operation, url, request, and downloadOperationCancelToken are packaged into SDWebImageDownloadToken, which the end of the download task.
        """

    do {
 
        let regex = try NSRegularExpression(pattern: "to",options: [])
        let results = text.match(regex: regex).map({ $0.0}).lazy
        debugPrint(results)
    } catch let err {
        debugPrint(err)
    }
}




