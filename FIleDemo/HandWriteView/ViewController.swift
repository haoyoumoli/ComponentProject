//
//  ViewController.swift
//  HandWriteView
//
//  Created by apple on 2021/5/27.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var handWriteView: HandWriteView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func clearBtnTouched(_ sender: Any) {
        handWriteView.clear()
    }
    
    @IBAction func genrateImageBtnTouched(_ sender: Any) {
     
        if  let image = handWriteView.scrawlImage {
            let data = image.pngData()
            do {
              try data?.write(to: URL(fileURLWithPath: "/Users/apple/Desktop/sssw.png"))
            } catch let err {
                debugPrint(err)
            }
        }
        
    }
}

