//
//  main.swift
//  WagesDemo
//
//  Created by apple on 2021/8/3.
//

import Foundation


startCalcauteWage()

//caculateToNowMonth3()

//func compareNSDecimalNumberAndDecimal() {
//
//    do {
//        
//        let behavior = NSDecimalNumberHandler.init(roundingMode: NSDecimalNumber.RoundingMode.bankers, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
//        let d1 = NSDecimalNumber.init(value: 1.0)
//        let d2 = NSDecimalNumber.init(value: 3.0)
//        var result  = d1.dividing(by: d2,withBehavior: behavior)
//        debugPrint(result)
//        result = result.dividing(by: 4.0,withBehavior: behavior)
//        debugPrint(result)
//    }
//
//    debugPrint()
//    do {
//        
//        let d1 = Decimal(1.0)
//        let d2 = Decimal(3.0)
//        var result = d1 / d2
//        debugPrint(result)
//        
//        result = result / Decimal(4.0)
//        let rr = UnsafeMutablePointer<Decimal>.allocate(capacity: 1)
//        NSDecimalRound(rr, &result, 2, NSDecimalNumber.RoundingMode.bankers)
//        debugPrint(rr.pointee)
//        rr.deinitialize(count: 1)
//        rr.deallocate()
//    }
//    
//}
//
//compareNSDecimalNumberAndDecimal()

//extension Date {
//    func
//    getDateComponents(
//        for calendar:Calendar = Calendar.current
//    )
//    -> DateComponents {
//        let dateComponents = calendar.dateComponents(in: TimeZone.current, from:self)
//        return dateComponents
//    }
//}


//func print2021CurrentPaidAnnualVacation()  {
//
//    guard
//        let month =  Date().getDateComponents().month
//    else {
//        return
//    }
//
//    let monthValues = [
//        (1,0.5),
//        (2,0.0),
//        (3,0.5),
//        (4,0.5),
//        (5,0.5),
//        (6,0.5),
//        (7,0.5),
//        (8,0.5),
//        (9,0.5),
//        (10,0.0),
//        (11,0.5),
//        (12,0.0),
//    ]
//
//    let usedValues = [0.5]
//    let items = monthValues.filter({$0.0 <= month })
//    let total = items.reduce(0, { $0 + $1.1})
//    let result = total - usedValues.reduce(0, +)
//
//    debugPrint("当前年假应为: \(result)")
//
//}
//
//
//print2021CurrentPaidAnnualVacation()
//extension String {
//    func getSubString(at location:Int,length:Int) -> String? {
//        if location < 0 ||
//            (location + length) >= self.count {
//            return nil
//        }
//
//        let begin = self.index(self.startIndex, offsetBy: location)
//        let end = self.index(begin, offsetBy: length)
//        return String(self[begin..<end])
//    }
//
//    func getSubString(at range:NSRange) -> String? {
//        return getSubString(at: range.location, length: range.length)
//    }
//
//    func match(regex:NSRegularExpression,mathOptions:NSRegularExpression.MatchingOptions = []) -> [(String,NSTextCheckingResult)] {
//        let result = regex.matches(in: self,options: mathOptions,
//                                    range: NSRange(location: 0, length: self.count) )
//        let retArr:[(String,NSTextCheckingResult)] = result.reduce([]) { rs, ele in
//            var rs = rs
//            if let sub = self.getSubString(at: ele.range) {
//                rs.append((sub,ele))
//            }
//            return rs
//        }
//
//        return retArr
//
//    }
//}

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




