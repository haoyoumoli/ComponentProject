//
//  UITextField+Combine.swift
//  CombineDemo
//
//  Created by apple on 2021/6/22.
//

import Foundation
import UIKit
import Combine

extension UITextField {
    var textDidChange:AnyPublisher<String,Never> {
        let result =  NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap({ return ($0.object as! UITextField).text })
            .eraseToAnyPublisher()
        return result
    }
    
    var didBeginEditing: AnyPublisher<Void,Never> {
        let result = NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification, object: self).map({ _ in return ()})
            .eraseToAnyPublisher()
        return result
    }
    
    var didEndEditing: AnyPublisher<Void,Never> {
        let result = NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification, object: self).map({ _ in return ()})
            .eraseToAnyPublisher()
        return result
    }
}
