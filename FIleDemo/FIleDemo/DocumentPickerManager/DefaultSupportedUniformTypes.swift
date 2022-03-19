//
//  DefaultSupportedUniformTypes.swift
//  FIleDemo
//
//  Created by apple on 2021/5/14.
//

import Foundation
import UniformTypeIdentifiers


enum DefaultSupportedUniformTypes:UniformTypeable {

    case image
    case text
    case plainText
    case pdf
    case rtf
    case msword
    case docx
  
    static func all() -> [DefaultSupportedUniformTypes] {
        return [.image,.text,.plainText,.pdf,.rtf,.msword,.docx]
    }
    
    // ----    UniformTypeable -----
    var uniformTypeIdentifiers: String? {
        switch self {
        case .image:
            return "public.image"
        case .text:
            return "public.text"
        case .plainText:
            return "public.plain-text"
        case .pdf:
            return "com.adobe.pdf"
        case .rtf:
            return "public.rtf"
        case .msword:
            return "com.microsoft.word.doc"
        case .docx:
            return "org.openxmlformats.wordprocessingml.document"
        }
    }
    
    @available(iOS 14.0,*)
    var utType: UTType? {
        switch self {
        
        case .image:
            return .image
        case .text:
            return .text
        case .plainText:
            return .plainText
        case .pdf:
            return .pdf
        case .rtf:
            return .text
        case .msword:
            return UTType.init("com.microsoft.word.doc")
        case .docx:
            return UTType.init("org.openxmlformats.wordprocessingml.document")
       
        }
    }
}
