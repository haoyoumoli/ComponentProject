//
//  ReauseableView.swift
//  ComplexListDemo
//
//  Created by apple on 2022/5/16.
//

import UIKit

protocol ReuseableView{
    static var reuseType:UIView.Type { get }
}

extension ReuseableView {
    static var reuseId:String {
        return String(reflecting:reuseType)
    }
}
