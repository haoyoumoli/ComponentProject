//
//  ViewController+DocumentInteractive.swift
//  FIleDemo
//
//  Created by apple on 2021/5/21.
//

import Foundation
import UIKit

extension ViewController {
    
    func moveFileToSandboxAndShare() {
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true)
        
        guard documentPaths.count > 0 else {
            debugPrint("NSSearchPathForDirectoriesInDomains retain empty array.")
            return
        }
        
        let documentPath = documentPaths.first!
        let filePath =  documentPath.appending("/1.txt")
        
        if let path = Bundle.main.path(forResource: "1", ofType: "txt")
        {
            if FileManager.default.fileExists(atPath:filePath) == false {
                do {
                    //try FileManager.default.moveItem(atPath: path, toPath: filePath)
                    
                    try FileManager.default.copyItem(at: URL(fileURLWithPath: path), to: URL(fileURLWithPath: filePath))
                }
                catch let error {
                    debugPrint("move file failed")
                    debugPrint(error)
                    return
                }
            }
            
            let url = URL(fileURLWithPath: filePath)
            let documentInteractionViewController = self.getAndRetainDocumentInteractiveController(for: url)
            documentInteractionViewController.presentOptionsMenu(from: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height), in: view, animated: true)
            //documentInteractionViewController.presentOpenInMenu(from: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height), in: view, animated: true)
        }
    }
    
    func getAndRetainDocumentInteractiveController(for url:URL) -> UIDocumentInteractionController {
        let a = UIDocumentInteractionController.init(url:url)
        a.url = url
        a.uti = "public.plain-text"
        self.documentInteractiveController = a
        return documentInteractiveController!
    }
    
    
}
