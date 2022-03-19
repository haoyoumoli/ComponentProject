//
//  ChainOfResponsibility.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/18.
//

import Foundation

///职责链

protocol Withdrawing {
    func withdraw(amount:Int) -> Bool
}


//MARK: -
final class MoneyPile: Withdrawing {
    
    let value: Int
    let quantity: Int
    let next: Withdrawing?
    
    init(value: Int,quantity:Int,next:Withdrawing?) {
        self.value = value
        self.quantity = quantity
        self.next = next
    }
    
    func withdraw(amount: Int) -> Bool {
        var amount = amount
        func canTakeSomeBill(want:Int) -> Bool {
            return (want / self.value) > 0
        }
        var quantity = self.quantity
        while canTakeSomeBill(want: amount) {
            if quantity == 0 {
                break
            }
            amount -= self.value
            quantity -= 1
        }
        guard amount > 0 else {
            return true
        }
        if let next = self.next {
            return next.withdraw(amount: amount)
        }
        return false
    }
}


//MARK: -
final class ATM: Withdrawing {
    
    private var hundred:Withdrawing
    private var fifty: Withdrawing
    private var twenty: Withdrawing
    private var ten: Withdrawing
    
    private var startPile: Withdrawing {
        self.hundred
    }
    
    init(hundred: Withdrawing,fifty: Withdrawing,twenty: Withdrawing, ten: Withdrawing) {
        self.hundred = hundred
        self.fifty = fifty
        self.twenty = twenty
        self.ten = ten
    }
    
    func withdraw(amount: Int) -> Bool {
        return startPile.withdraw(amount: amount)
    }

    static func testATM() {
        let ten = MoneyPile(value: 10, quantity: 6, next: nil)
        let twenty = MoneyPile(value: 20, quantity: 2, next: ten)
        let fifty = MoneyPile(value: 50, quantity: 2, next: twenty)
        let hundred = MoneyPile(value: 100, quantity: 1, next: fifty)
        
        let atm = ATM(hundred: hundred, fifty: fifty, twenty: twenty, ten: ten)
        debugPrint(atm.withdraw(amount: 320))
        debugPrint(atm.withdraw(amount: 300))
    }
}



