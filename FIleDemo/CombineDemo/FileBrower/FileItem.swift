//
//  FileItem.swift
//  CombineDemo
//
//  Created by apple on 2021/7/2.
//

import Foundation

class FileItem {
    
    let fileUrl:URL
   
    init(fileUrl:URL) {
        self.fileUrl = fileUrl
    }
    
    var subItems:[FileItem] = []
    
    var level:Int? = nil
    
    fileprivate(set) var fileName:String? = nil
    
    fileprivate(set) var isDir:Bool = false
}

//MARK: -
extension FileItem: CustomStringConvertible {
    var description: String {
        return "<FileItem:\(fileUrl)\n  \(isDir ? "D" : "")>\n"
    }
}

//MARK: -
extension FileItem {
    
    static func fileItemsForDirPath(_ dirPath:String) -> [FileItem] {
        
        guard let fileNames =  try? FileManager.default.contentsOfDirectory(atPath: dirPath) else {
            return []
        }
        
        return fileNames.map({
            i in
            let url = URL(fileURLWithPath: "\(dirPath)/\(i)")
            let fileWrapper = try? FileWrapper.init(url: url, options: FileWrapper.ReadingOptions.withoutMapping)
            
            let item = FileItem.init(fileUrl: url)
            item.isDir = fileWrapper?.isDirectory ?? false
            item.fileName = fileWrapper?.filename
            return item
        })
        .sorted(by: { return $0.fileUrl.absoluteString < $1.fileUrl.absoluteString})
        
  
    }
}
