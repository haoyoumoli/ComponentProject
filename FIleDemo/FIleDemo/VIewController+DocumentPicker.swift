//
//  VIewController+DocumentPicker.swift
//  FIleDemo
//
//  Created by apple on 2021/5/21.
//

import Foundation
import UIKit

extension ViewController {
    func hanldePickedDocument(picker:UIDocumentPickerViewController,urls:[URL]) {
        for aurl in urls {
            guard aurl.startAccessingSecurityScopedResource() else {
                continue
            }
            defer { aurl.stopAccessingSecurityScopedResource() }
            
            var error:NSError? = nil
            NSFileCoordinator().coordinate(readingItemAt: aurl , error: &error, byAccessor: { (u) in
                let keys :[URLResourceKey] = [.nameKey,.isDirectoryKey]
                
                if u.isLocalDirectory {
                    //是文件夹的时候遍历文件夹
                    guard let fileList = FileManager.default.enumerator(at: u, includingPropertiesForKeys:keys) else {
                        debugPrint("Unable to assess the contents of \(u.path)")
                        return
                    }
                    
                    for case let file as URL in fileList {
                        guard u.startAccessingSecurityScopedResource() else {
                            continue
                        }
                        
                        // Do something with the file here.
                        debugPrint("chosen file: \(file.lastPathComponent)")
                        
                        u.stopAccessingSecurityScopedResource()
                    }
                }
                
                else {
                    debugPrint("file:\(u)")
                    debugPrint("fileSize:\(u.localFileSize ?? 0)")
                }
            })
            
            if error != nil {
                debugPrint("error:")
                debugPrint(error ?? "")
            }
        }
    }
    
    func hanldePickedDocument2(picker:UIDocumentPickerViewController,urls:[URL]) {
        
        guard urls.count == 1 else {
            debugPrint("不支持多选")
            return
        }
        let url = urls.first!
        
        guard url.isLocalDirectory == false  else {
            debugPrint("不支持选择文件夹")
            return
        }
        
//        defer { url.stopAccessingSecurityScopedResource() }
//
//        guard url.startAccessingSecurityScopedResource() else {
//            debugPrint("startAccessingSecurityScopedResource failed")
//            return
//        }
        debugPrint("开始处理")
        
        var error:NSError?
        NSFileCoordinator().coordinate(readingItemAt: url, error: &error) { u in
            //if u.startAccessingSecurityScopedResource() {
                debugPrint("得到数据:\(u)")
              //  u.stopAccessingSecurityScopedResource()
           // }
        }
        
        if let e = error {
            debugPrint("error:\(e)")
        } else {
            debugPrint("处理成功")
        }
    }
}
