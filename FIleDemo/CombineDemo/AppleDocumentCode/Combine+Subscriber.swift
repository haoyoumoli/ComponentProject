//
//  Combine+Subscriber.swift
//  CombineDemo
//
//  Created by apple on 2021/6/10.
//

import Foundation
import Combine


//MARK: - Processing Published Elements with Subscribers

extension CombineCode {
    func mySubscriberDemo() {
        
        let timerPub = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
        
        class MySubscriber: Subscriber {
            var subscription: Subscription?
            typealias Input = Date
            typealias Failure = Never
            
            func receive(subscription: Subscription) {
                print("published                             received")
                self.subscription = subscription
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    subscription.request(.max(3))
                }
            }
            
            func receive(_ input: Date) -> Subscribers.Demand {
                debugPrint("receive:\(input)")
                return Subscribers.Demand.none
            }
            
            func receive(completion: Subscribers.Completion<Never>) {

                debugPrint("-- done --")
            }
        }
        
        let mySub = MySubscriber()
        

        timerPub.subscribe(mySub)
        
        self.mySub = mySub
    }
    
}
