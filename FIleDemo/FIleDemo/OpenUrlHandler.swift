//
//  OpenUrlHandler.swift
//  FIleDemo
//
//  Created by apple on 2021/5/7.
//

import Foundation
import UIKit

class OpenUrlHandler {
    
    enum SourceApp: String {
        
        case appleFile = "com.apple.DocumentsApp"
        
        case safari = "com.apple.mobilesafari"
        
        case unknown = "unknown"
        
        init(string:String) {
            switch string {
            case  "com.apple.DocumentsApp":
                self = .appleFile
            case  "com.apple.mobilesafari":
                self = .safari
            default:
                self = .unknown
            }
        }
    }
    
    private(set) var options:[UIApplication.OpenURLOptionsKey : Any] = [:]
    
    private(set) var url:URL? = nil
    
    private(set) var soruceApp:SourceApp = .unknown
}

extension OpenUrlHandler {
    
    func prepareHandle(url:URL ,options: [UIApplication.OpenURLOptionsKey : Any] ) -> Bool {
        
        self.options = [:]
        self.url = nil
        self.soruceApp = .unknown
        
        debugPrint("---prepareHandle---")
        debugPrint(url)
        debugPrint(options)
        
        guard
            let sourceApp = options[.sourceApplication] as? String else  {
            return false
        }
        
        let type = SourceApp.init(string: sourceApp)
        switch type {
        case .unknown: return false
            
        default:
            self.options = options
            self.url = url
            self.soruceApp = type
            return true
        }
    }
    
}
