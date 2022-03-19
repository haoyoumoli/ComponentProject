//
//  ViewController+WriteFile.swift
//  FIleDemo
//
//  Created by apple on 2021/5/21.
//

import Foundation
import UIKit



extension ViewController {
    
    /// 创建文件(如果文件不存在)
    /// - Parameter filePath: 文件的路径
    func createFileIfNeeded(filePath:String) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: filePath ) {
            fileManager.createFile(atPath: filePath, contents: nil, attributes: [FileAttributeKey.immutable:false])
        }
    }
    
    /// 向文件中写入数据,支持增量写入与重新覆盖写入
    /// - Parameters:
    ///   - data: 写入的数据
    ///   - filePath: 文件路径
    ///   - appending: 是否为增量写入
    func writeDataToFile(data:Data,filePath:String,appending:Bool) {
        
        let isWriteable = FileManager.default.isWritableFile(atPath: filePath)
        guard isWriteable == true else  {
            debugPrint("\(filePath) is not writeable")
            return
        }
        
        let fileHandle:FileHandle? = FileHandle.init(forWritingAtPath: filePath)
        if appending {
            ///追加写入,将指针移动到最后
            fileHandle?.seekToEndOfFile()
        } else {
            ///重新写入,阶段文件
            fileHandle?.truncateFile(atOffset: 0)
        }
        
        if let wfh = fileHandle {
            wfh.write(data)
            wfh.closeFile()
        } else {
            debugPrint("Failed to create FileHandle for write")
        }
    }
    
    
    func writeAFile() {
        let filePath = "/Users/apple/Desktop/file-handle-demo"
        createFileIfNeeded(filePath: filePath)
        
        let data = "123 456 789".data(using: .utf8)!
        writeDataToFile(data: data, filePath: filePath,appending: false)
    }
    
    func readFile() {
        let filePath = "/Users/apple/Desktop/file-handle-demo"
        if let readFileHandle = FileHandle.init(forReadingAtPath: filePath) {
            let data = readFileHandle.readDataToEndOfFile()
            let str = String(data: data, encoding: .utf8)
            readFileHandle.closeFile()
            debugPrint(data,str as Any)
        }
        
    }
}
