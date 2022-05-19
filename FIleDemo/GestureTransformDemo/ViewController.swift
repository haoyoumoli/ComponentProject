//
//  ViewController.swift
//  GestureTransformDemo
//
//  Created by apple on 2022/5/19.
//

import UIKit

class ViewController: UIViewController {

    let redView = UIButton()
    
    lazy private(set) var startLongProgressLocation:CGPoint = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        redView.setTitle("长按我左右拖拽", for: .normal)
        redView.backgroundColor = .red
        redView.translatesAutoresizingMaskIntoConstraints  = false
        redView.addTarget(self, action: #selector(redViewTouched(_:)), for: .touchUpInside)
        let longProgressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongProgressGesture(_:)))
        redView.addGestureRecognizer(longProgressGesture)
        view.addSubview(redView)
        
        NSLayoutConstraint.activate([
            redView.widthAnchor.constraint(equalToConstant: 300),
            redView.heightAnchor.constraint(equalToConstant: 300),
            redView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            redView.topAnchor.constraint(equalTo: view.topAnchor,constant: 60)
        ])
    }

    @objc
    func redViewTouched(_ sender:UIButton) {
        debugPrint("redViewTouched")
    }
    
    @objc
    func handleLongProgressGesture(_ sender:UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .possible:
            break
        case .began:
            startLongProgressLocation = sender.location(in: view)
        case .changed:
            let nowLoction = sender.location(in: view)
            let deltaX = nowLoction.x - startLongProgressLocation.x
            self.redView.transform = CGAffineTransform(translationX: deltaX, y: 0)
        case .ended,.failed,.cancelled:
            break
          //  self.redView.transform = .identity
        @unknown default:
            self.redView.transform = .identity
        }
        
        debugPrint(#function)
    }
}

