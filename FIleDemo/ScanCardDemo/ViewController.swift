//
//  ViewController.swift
//  ScanCardDemo
//
//  Created by apple on 2021/11/16.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    var manager:EXOCRIDCardRecoManager? = nil
    
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            let image = UIImage(named: "IMG_0846.JPG")
        else {
            debugPrint("图片不存在")
            return
        }
        
        oldSaveImageMethod()
        
        PHPhotoLibrary.shared()
      
    }
    
    func oldSaveImageMethod() {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(didFinishWriteImage(_:error:contextInfo:)), nil )
    }

    
    func testScanIdCard() {
        label.numberOfLines = 0
        label.frame = view.bounds
        view.addSubview(label)
        
        view.backgroundColor = .gray
        let version = EXOCRCardEngineManager.getSDKVersion()
        EXOCRCardEngineManager.initEngine()
        debugPrint(version)
        // Do any additional setup after loading the view.
        
        DispatchQueue.main.async {
            guard let manager = EXOCRIDCardRecoManager.sharedManager(self) else  {
                return
            }
            manager.setDisplayLogo(false)
            manager.setEnablePhotoRec(false)
            
//            manager.recoIDCardFromStream(withSide: true, onCompleted: { statusCode, info in
//                debugPrint("completed",statusCode,info?.toString() ?? "nil ")
//                self.label.text = info?.toString() ?? ""
//            }, onCanceled: { statusCode in
//                debugPrint("canceled",statusCode)
//            }, onFailed: { statusCode, imge in
//                debugPrint("onfailed",statusCode,imge)
//            })
            
            //设置自定义扫描视图
            let scanView = CustomScanView(frame: UIScreen.main.bounds)
            guard
                manager.setCustomScanView(scanView)
            else {
                debugPrint("设置自定义扫描视图失败")
                return
            }
            
            manager.recoIDCardFromStreamByCustomScanView(withSide: true)
        }
    }
   
    @objc func didFinishWriteImage(_ image:UIImage,error:NSError?,contextInfo:UnsafeMutableRawPointer?) {
        if let e = error {
            debugPrint(e)
        }
    }
    
}

