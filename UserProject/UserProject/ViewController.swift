//
//  ViewController.swift
//  UserProject
//
//  Created by apple on 2022/2/10.
//

import UIKit


protocol Coffee {
    
}

struct RegularCoffee: Coffee {}
struct Cappuccino: Coffee {}

extension Coffee where Self == Cappuccino {
    static var cappucino:Cappuccino  { Cappuccino() }
}

func brew<CoffeeType:Coffee>(_ :CoffeeType) {
    
}

class ViewController: UIViewController {
 
    override func viewDidLoad() {
        super.viewDidLoad()
        Cappuccino.cappucino
        brew(.cappucino)
    }

    
    func aaa() -> [String] {
        
    }
}

