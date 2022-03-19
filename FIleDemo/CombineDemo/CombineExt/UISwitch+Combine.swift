//
//  UISwitch+Combine.swift
//  CombineDemo
//
//  Created by apple on 2021/6/23.
//

import Foundation
import UIKit
import Combine

extension CombineCompatible where Self:UISwitch {
    
    var isOnPublisher:AnyPublisher<Bool,Never> {
        return publisher(for: [.allEditingEvents,.valueChanged])
            .map({ return $0.isOn })
            .eraseToAnyPublisher()
    }
}


