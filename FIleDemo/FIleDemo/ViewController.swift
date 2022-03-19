//
//  ViewController.swift
//  FIleDemo
//
//  Created by apple on 2021/5/7.
//

import UIKit
import UniformTypeIdentifiers


class ViewController: UIViewController {
    
    private var documentPickerManager = DocumentPickerManager()
    
    lazy var documentInteractiveController:UIDocumentInteractionController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
       
    }
    
    @IBAction func writeFileTouched(_ sender: Any) {
        self.writeAFile()
    }
    
    @IBAction func openFileAppBtnTouched(_ sender:UIButton) {
       
        printCost(label: "present document picker") {
            let documentPickController = documentPickerManager.getImportDocumenPickertViewController(for: DefaultSupportedUniformTypes.all(), didPickDocument: {
                [weak self]
                (picker, urls) in
                self?.hanldePickedDocument2(picker: picker, urls: urls)
            }, didCancel: nil)
            
            self.present(documentPickController, animated: true, completion: nil)
        }
       
    }
    
    @IBAction func systemOp(_ sender: Any) {
        self.moveFileToSandboxAndShare()
        
    }
    
    @IBAction func readFile(_ sender: Any) {
        self.readFile()
    }
}




