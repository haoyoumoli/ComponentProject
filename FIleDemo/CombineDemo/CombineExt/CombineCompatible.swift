//
//  CombineCompatible.swift
//  CombineDemo
//
//  Created by apple on 2021/6/23.
//

import Foundation
import UIKit
import Combine

///源码参考: https://github.com/AvdLee/CombineSwiftPlayground

protocol CombineCompatible { }


final class UIControlSubscription<SubscriberType:Subscriber,Control:UIControl>: Subscription where SubscriberType.Input == Control {
    
    private var subscriber:SubscriberType?
    
    private let control: Control
    
    init(subscriber: SubscriberType,control:Control,event:UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        control.addTarget(self, action: #selector(eventHandler), for: event)
    }
    
    func request(_ demand: Subscribers.Demand) {
        
    }
    
    func cancel() {
        subscriber = nil
    }
    
    @objc private func eventHandler() {
        _ = subscriber?.receive(control)
    }
}

struct UIControlPublisher<Control: UIControl>:Publisher {
    
    typealias Output = Control
    
    typealias Failure = Never
    
    let control:Control
    let controlEvents: UIControl.Event
    
    init(control: Control,events: UIControl.Event) {
        self.control = control
        self.controlEvents = events
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, S.Failure == UIControlPublisher.Failure , S.Input == UIControlPublisher.Output {
        let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: controlEvents)
        subscriber
            .receive(subscription:subscription)
    }
    
}

