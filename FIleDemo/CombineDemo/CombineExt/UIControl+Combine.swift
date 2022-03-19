//
//  UIButton.swift
//  CombineDemo
//
//  Created by apple on 2021/6/22.
//

import Foundation
import UIKit
import Combine

extension UIControl:CombineCompatible { }

extension CombineCompatible where Self:UIControl {
    func publisher(for events: UIControl.Event) -> UIControlPublisher<Self> {
        return UIControlPublisher.init(control: self, events: events)
    }
}


