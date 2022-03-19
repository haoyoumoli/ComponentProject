//
//  FileContentAppender.swift
//  MemoryLayoutTestDemo
//
//  Created by apple on 2021/11/5.
//

import Foundation

extension FileHandle {
    static func appendContent(
        filePath:String,
        content:String,
        create:Bool = true)
    {
        guard
            filePath.isEmpty == false
        else { return }
        if FileManager.default.fileExists(atPath: filePath) == false {
            guard
                create,
                FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil) else {
                debugPrint("文件创建失败")
                return
            }
        }
        
        guard let fileHandler = FileHandle(forWritingAtPath: filePath) else {
            debugPrint("文件打开失败")
            return
        }
       
        defer { try? fileHandler.close()}
        do {
           try fileHandler.seekToEnd()
            guard let writeData = "\(content)\n".data(using: .utf8) else {
                debugPrint("构造写入数据失败")
                return
            }
           try fileHandler.write(contentsOf:writeData)
        } catch let err {
            debugPrint("写入失败:\(err)")
        }
      
    }
}
