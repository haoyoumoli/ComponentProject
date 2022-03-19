//
//  uuuu.swift
//  FIleDemo
//
//  Created by apple on 2021/5/14.
//


import Foundation
import UniformTypeIdentifiers
import UIKit

final class DocumentPickerManager: NSObject,UIDocumentPickerDelegate {
    
    typealias DidPickDocumentHandler = (_ controller:UIDocumentPickerViewController,_ urls:[URL]) -> Void
    var didPickDocument:DidPickDocumentHandler? = nil
    
    typealias DidCancelHandler = (_ controller:UIDocumentPickerViewController) -> Void
    var didCancel:DidCancelHandler? = nil
    
    func getImportDocumenPickertViewController(for types:[UniformTypeable],
        didPickDocument:@escaping DidPickDocumentHandler, didCancel: DidCancelHandler? = nil ) -> UIDocumentPickerViewController {
        
        let documentPickController: UIDocumentPickerViewController
        
        if #available(iOS 14.0, *) {
            let uttypes = types.compactMap{ $0.utType }
            documentPickController =
                UIDocumentPickerViewController.init(forOpeningContentTypes:uttypes ,asCopy: true)
        } else {
            let documentTypes = types.compactMap{ $0.uniformTypeIdentifiers }
            documentPickController = UIDocumentPickerViewController.init(documentTypes: documentTypes, in: .import)
        }
        
        documentPickController.delegate = self
        
        self.didPickDocument = didPickDocument
        self.didCancel = didCancel
        
        return documentPickController
    }
    
    @available(iOS 11.0, *)
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        didPickDocument?(controller,urls)
        didPickDocument = nil
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        didCancel?(controller)
        didCancel = nil
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        didPickDocument?(controller,[url])
        didPickDocument = nil
    }
}


