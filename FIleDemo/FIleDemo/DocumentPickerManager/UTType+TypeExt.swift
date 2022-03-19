//
//  UTTypeExtension.swift
//  FIleDemo
//
//  Created by apple on 2021/5/14.
//

import Foundation

import UniformTypeIdentifiers


/**
 苹果 UniformTypeIdentifiers 网址
 https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html
 
 mimetype
 https://blog.csdn.net/lxw1844912514/article/details/102629405
 */

@available(iOS 14.0,*)
extension UTType {
    static let msword = UTType.init(mimeType: "application/msword")
    
    static let docx = UTType.init(mimeType: "application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    
    static let dotx = UTType.init(mimeType: "application/vnd.openxmlformats-officedocument.wordprocessingml.template")
    
    static let docm = UTType.init(mimeType: "application/vnd.ms-word.document.macroEnabled.12")
    
    static let dotm = UTType.init(mimeType: "application/vnd.ms-word.template.macroEnabled.12")
    
}
