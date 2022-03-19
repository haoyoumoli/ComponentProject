//
//  Mediator.swift
//  DesignPatternInSwift
//
//  Created by apple on 2021/5/18.
//

import Foundation

///中介者模式
///用一个中介者对象封装一系列的对象交互，中介者使各对象不需要显示地相互作用，从而使耦合松散，而且可以独立地改变它们之间的交互。

protocol Receiver {
    associatedtype MessageType
    
    func receive(message: MessageType)
}

protocol Sender {
    associatedtype MessageType
    associatedtype RecieveType: Receiver
    
    var recipients: [RecieveType] { get }
    
    func send(message: MessageType)
}


struct Programmer {
    let name: String
    
    init(name: String) {
        self.name = name
    }
}


extension Programmer: Receiver {
    func receive(message: String) {
        debugPrint("\(name) received: \(message)")
    }
}


final class MessageMediator: Sender {
    
    internal var recipients: [Programmer] = []
    
    func add(recipient: Programmer) {
        recipients.append(recipient)
    }
    
    func send(message: String) {
        for  recipient in recipients {
            recipient.receive(message: message)
        }
    }
}

func testMessageMediator() {
    func spamMonster(message: String, worker: MessageMediator) {
        worker.send(message: message)
    }
    
    let messageMediator = MessageMediator()
    let user0 = Programmer(name: "Linus Torvalds")
    let user1 = Programmer(name: "Avadis 'Avie' Tevanian")
    messageMediator.add(recipient: user0)
    messageMediator.add(recipient: user1)
    
    spamMonster(message: "I'd Like to Add you to My Professional Network", worker: messageMediator)
}
