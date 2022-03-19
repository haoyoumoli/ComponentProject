//
//  DeviceInfo.swift
//  AddressBookDemo
//
//  Created by apple on 2021/12/1.
//

import Foundation

struct HardWareInfo {
    
    /// 获取设备cpu个数
    /// - Returns: cpu个数
    static func getCountOfCores() -> Int {
        var result = 1
        var size = MemoryLayout.stride(ofValue: result)
        _ = "hw.ncpu".withCString { pointer in
            sysctlbyname(pointer, &result, &size, nil, 0);
        }
        return result
    }
}


class AsyncTaskPerformer {
    
    static let shared = AsyncTaskPerformer()
    
    private var queueMap = [Int:DispatchQueue]()
    private var flag:Int = 0
    let countOfCpu:Int
    
    private init() {
        countOfCpu = HardWareInfo.getCountOfCores()
    }
    
    private func getQueue() -> DispatchQueue {
        ///懒加载queue
        var queue:DispatchQueue? = queueMap[flag]
        if queue == nil {
            queue =  DispatchQueue.init(label: "AsyncTaskPerformer.queue.\(flag)")
            queueMap[flag] = queue
        }
        flag += 1
        if flag >= countOfCpu {
            flag = 0
        }
        return queue!
    }
    
    func perform(_ block: @escaping ()->Void) {
        getQueue().async(execute:block)
    }
    
}

