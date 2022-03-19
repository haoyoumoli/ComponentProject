//
//  ClockViewController.swift
//  CombineDemo
//
//  Created by apple on 2021/6/11.
//

import Foundation
import UIKit
import Combine

class ClockViewController: UIViewController {
    
    @IBOutlet weak var timeLbl: UILabel!
    
    private(set) var subscriberCancelers = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    deinit {
        debugPrint(#function)
    }
}

//MARK: - Actions
extension ClockViewController {
    
    func setupActions() {
        
        let dateFormat = DateFormatter.init()
        dateFormat.dateFormat = "HH : mm : ss"
    
        ///监听系统时钟事件,每秒一次
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink(receiveCompletion: { _ in
                debugPrint("完成了")
            },
            receiveValue: {
                [weak self] date in
                ///runloop ---> ... ---> block ---> self
                self?.changeTimeDisplay(dateFormatter: dateFormat, date: date)
            })
            .store(in: &subscriberCancelers)
    }
}

//MARK: - UI
extension ClockViewController {
    func setupUI() {
        timeLbl.backgroundColor = UIColor.lightGray
        timeLbl.layer.borderWidth = 1.0
        timeLbl.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    func changeTimeDisplay(dateFormatter:DateFormatter,date:Date) {
        let string = dateFormatter.string(from: date)
        self.timeLbl.text = string
    }
}
