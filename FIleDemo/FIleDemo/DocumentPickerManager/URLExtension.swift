//
//  URLExtension.swift
//  FIleDemo
//
//  Created by apple on 2021/5/7.
//

import Foundation

extension URL {
    
    /// 获取本地文件是否为文件夹
    var isLocalDirectory:Bool {
        if isFileURL == false { return false }
        if let values = try? self.promisedItemResourceValues(forKeys: [.isDirectoryKey]),
        let isDirectory = values.isDirectory
        {
            return isDirectory
        }
        else
        {
            return false
        }
    }
    
    
    /// 本地文件大小
    var localFileSize:Int?  {
        if let values = try? self.promisedItemResourceValues(forKeys: [.fileSizeKey]) ,
           let result = values.fileSize {
            return result
        } else {
            return nil
        }
    }
    
}
