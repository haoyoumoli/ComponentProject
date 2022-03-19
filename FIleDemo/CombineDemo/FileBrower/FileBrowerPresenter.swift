//
//  FileBrowerPresenter.swift
//  CombineDemo
//
//  Created by apple on 2021/7/2.
//

import Foundation
import UIKit

func printCost(label:String,block:()->Void) {
    let date1 = Date()
    block()
    debugPrint(label,"cost",Date().timeIntervalSince(date1))
}

class FileBrowerPreseter:NSObject {
    var fileItems:[FileItem] = []
    
    weak var tableView:UITableView?
    
    func load() {
        printCost(label: "loadfilenames") {
            self.fileItems = FileItem.fileItemsForDirPath("/Users/apple/Downloads")
            tableView?.reloadData()
        }
            
    }
    
}


extension FileBrowerPreseter:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseid")!
        let item = fileItems[indexPath.row]
        var space = ""
        for _ in 0..<(item.level ?? 0) {
            space += "  "
        }
        cell.textLabel?.text = space + (item.fileName ?? item.fileUrl.absoluteString)
        cell.textLabel?.textColor = item.isDir ? UIColor.blue : UIColor.black
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = fileItems[indexPath.row]
        
        if item.isDir {
            ///展示或者隐藏子文件夹
            if item.subItems.count == 0 {
                showSubItems(for: item, itemIdx: indexPath.row)
            } else {
                hiddenSubItems(for: item)
            }
        }
       
    }
    
    private func  showSubItems(for item:FileItem,itemIdx:Int) {
        item.subItems = FileItem.fileItemsForDirPath(item.fileUrl.path)
        
        //设置文件夹深度
        item.subItems.forEach({
            $0.level = (item.level ?? 0) + 1
        })
        
        if itemIdx + 1 == fileItems.count {
            fileItems.append(contentsOf:item.subItems)
        } else {
            fileItems.insert(contentsOf: item.subItems, at: itemIdx + 1)
        }
        tableView?.reloadData()
    }
    
    private func hiddenSubItems(for item:FileItem) {
        fileItems.removeAll(where: {
            j in
            let result = (j.fileUrl.path != item.fileUrl.path) && (j.fileUrl.path.hasPrefix(item.fileUrl.path) && ((j.level ?? 0) > (item.level ?? 0)))
            
            return result
        })
        item.subItems.removeAll()
        tableView?.reloadData()
    }
    
}
