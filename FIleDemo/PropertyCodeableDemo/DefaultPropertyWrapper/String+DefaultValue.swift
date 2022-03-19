//
//  String+DefaultValue.swift
//  PropertyCodeableDemo
//
//  Created by apple on 2021/5/17.
//

import Foundation

extension String {
    enum Empty:DefaultValue {
        static let defaultValue = ""
    }
}
