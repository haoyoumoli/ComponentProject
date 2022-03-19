//
//  CombineCode.swift
//  CombineDemo
//
//  Created by apple on 2021/6/9.
//

import Foundation
import Combine

extension Notification.Name {
    static let demoEvent = Notification.Name.init("CombineDemo.demoevent")
}


class CombineCode:NSObject {
    
    
    /// 相当于rxswift disposeable
    var cancelables = Set<AnyCancellable>()
    
    @objc var userInfo = UserInfo()
    
    var mySub:Any? = nil
    
    func main() {
        //demo1()
        //usingOperator()
        //sequenceDemo()
        //catchDemo()
        //anyPublisherDemo()
        //publishedDemo()
        //anycancelableDemo()
        //futureDemo()
        //justDemo()
        //deferredDemo()
        //emptyDemo()
        //connectableDemo()
        //autoConnectDemo()
        //subjectDemo()
        //passthroughSubjectDemo()
        //mySubscriberDemo()
        //replaceCompletionHandlerWithFutures()
       // replaceRepeatedlyInvokedClosuresWithSubjects()
        recordDemo()
    }
    
    
    
    deinit {
      
    }
}

//MARK: - Subjects
extension CombineCode {
    
    
    func passthroughSubjectDemo() {
        ///可以不设置初始值
        let subject = PassthroughSubject<Int, NSError>()
        
        subject.sink(receiveCompletion: {
            switch $0 {
            case .finished:
                debugPrint("完成")
            case .failure(let err):
                debugPrint(err)
            }
        }, receiveValue: {
            debugPrint("receiveValue1:\($0)")
        })
        .store(in: &cancelables)
        
        subject.send(4)
        subject.send(5)
        subject.send(completion: .failure(NSError.init(domain: "combine.demo", code: -1, userInfo: nil)))
    }
    
    
    func subjectDemo() {
        let subject = CurrentValueSubject<Int, NSError>.init(2)
        
       subject.sink(receiveCompletion: {
            switch $0 {
            case .finished:
                debugPrint("完成")
            case .failure(let err):
                debugPrint(err)
            }
        }, receiveValue: {
            debugPrint("receiveValue:\($0)")
        })
       .store(in: &cancelables)
        
        subject.send(2)
        subject.send(3)
        
        ///发送完成
        //subject.send(completion: Subscribers.Completion<NSError>.finished)
        
        ///发送错误
        subject.send(completion: .failure(NSError.init(domain: "combine.demo", code: -1, userInfo: nil)))
    }
    
}

//MARK: - Connectable Publishers
extension CombineCode {
    
    
    func autoConnectDemo() {
        
       Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect().sink(receiveValue: {
                date in
                debugPrint("Date now:\(date)")
            }).store(in: &cancelables)
    }
    
    
    ///可以指定发射源元素的时机,在准备好之后再发射元素.
    ///而不是订阅者订阅就发射元素
    func connectableDemo() {
        debugPrint("connectableDemo")
        let conectableJust = Just([1,2,3]).makeConnectable()
        
       conectableJust.sink(receiveCompletion: {
            debugPrint("receiveCompletion:\($0)")
        }, receiveValue: {
            debugPrint("receiveValue:\($0)")
        })
       .store(in: &cancelables)
        
        ///2秒后 订阅者才能接受到元素
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            _ = conectableJust.connect()
        }
        
    }
    
}


//MARK: - Convenience Publishers
extension CombineCode {

    // ???没看懂官方代码
    func recordDemo() {
        Record<Int,Never>.init { recording  in
            recording.receive(2)
            recording.receive(3)
            recording.receive(completion: .finished)
        }.sink(receiveValue: {
            debugPrint("receiveValue:\($0)")
        }).store(in: &cancelables)
        
        
    }
    
    func deferredDemo() {
        let deffered = Deferred {
            return Just("deffered just")
        }
        
        _ = deffered.sink(receiveCompletion: {
            debugPrint("receiveCompletion:\($0)")
        }, receiveValue: {
            debugPrint("receiveValue:\($0)")
        })
        
    }
    
    func justDemo() {
        //产生一个值,然后就结束
        
        let just = Just.init("JUST")
        _ = just.sink(receiveCompletion: {
            debugPrint("receiveCompletion:\($0)")
        }, receiveValue: {
            debugPrint("receiveValue:\($0)")
        })
    }
    
    func futureDemo() {
        //产生一个值,然后就结束或者失败
        let future = Future<String, NSError>.init { promise in
            let result = Result<String, NSError>.success("YES")
            
            promise(result)
        }
        
        _ = future.sink(receiveCompletion: {
            debugPrint("receiveCompletion:\($0)")
        }, receiveValue: {
            debugPrint("receiveValue:\($0)")
        })
        
        let future2 = Future<String, NSError>.init { promise in
            let result = Result<String, NSError>.failure(NSError.init(domain: "combine.demo", code: -1, userInfo: nil))
            
            promise(result)
        }
        
        _ = future2.sink(receiveCompletion: {
            debugPrint("receiveCompletion2:\($0)")
        }, receiveValue: {
            debugPrint("receiveValue2:\($0)")
        })
    }
    
    func emptyDemo() {
        ///不发送任何元素, 直接结束
        
        let empty = Empty<String, NSError>.init(completeImmediately: true)

        _ = empty.sink(receiveCompletion: {
            debugPrint("receiveCompletion:\($0)")
        }, receiveValue: {
            debugPrint("receiveValue:\($0)")
        })
        
    }
  
    
    func failDemo() {
        let failpublisher = Fail<Any, NSError>(error: NSError.init(domain: "combine.demo", code: -1, userInfo: nil))
        
        _ = failpublisher.sink(receiveCompletion: {
            debugPrint("receiveCompletion:\($0)")
        }, receiveValue: {
            debugPrint("receiveValue:\($0)")
        })
    }
    
}

//MARK: - publishers
extension CombineCode {
    func sequenceDemo() {
        
        var publisher =  Publishers.Sequence<[Int], Error>.init(sequence: [1,2,3,4,5,6])
        
        publisher = publisher.append([7,8,9,10])
        
        _ = publisher.sink(receiveCompletion: {
            debugPrint("receiveCompletion:\($0)")
        }, receiveValue: {
            debugPrint("receiveValue:\($0)")
        })
        
        _ = publisher.sink(receiveCompletion: {
            debugPrint("2 receiveCompletion:\($0)")
        }, receiveValue: {
            debugPrint("2 receiveValue:\($0)")
        })
        
    }
    
    func catchDemo() {
        
        let intPub = Publishers.Sequence<[Int], Error>.init(sequence: [1,2,3,4,5,6])
        
        
        let catchPub = Publishers.Catch.init(upstream: intPub) { error in
            return Publishers.Sequence<[Int], Error>.init(sequence: [])
        }
        
        _ =  catchPub.sink(receiveCompletion: {
            debugPrint("receiveCompletion:\($0)")
        }, receiveValue: {
            debugPrint("receiveValue:\($0)")
        })
    }
    
    func anyPublisherDemo() {
        
        ///包装器,用来包赚其它的publisher
        debugPrint(#function)
        
        let intPub = Publishers.Sequence<[Int], Error>.init(sequence: [1,2,3,4,5,6])
        
        let anypublisher = AnyPublisher(intPub)
        
        _ = anypublisher.sink(receiveCompletion: {
            debugPrint("receiveCompletion:\($0)")
        }, receiveValue: {
            debugPrint("receiveValue:\($0)")
        })
    }
    
    func publishedDemo() {
        class Weather {
            ///类专用, struct不能用
            @Published var temperature:Double
            init(temperature:Double) {
                self.temperature = temperature
            }
        }
        
        let weather = Weather(temperature: 20)
        _ = weather.$temperature.sink(receiveCompletion: {
                                        debugPrint("receiveCompletion:\($0)")},
                                      receiveValue: {debugPrint("receiveCompletion:\($0)")})
        
        weather.temperature = 25
    }
    
    func anycancelableDemo() {
        
        ///AnyCancellable会在释放时调用这个闭包
        let anyCancel = AnyCancellable.init {
            
            debugPrint("AnyCancellable Cancel Callback")
        }
        
        debugPrint("anycancelableDemo")
        
    }
    
    
}

//MARK: 基本使用
extension CombineCode {
    /// 基本使用
    private func demo1() {
        let publisher = NotificationCenter.default.publisher(for: Notification.Name.demoEvent)
        
        let cancelable = publisher.sink { completion in
            debugPrint("completion:\(completion)")
        } receiveValue: { notification in
            debugPrint("notification:\(notification)")
        }
        
        cancelable.store(in: &cancelables)
        
        ///发射元素
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            debugPrint("start emit element")
            
            NotificationCenter.default.post(name: NSNotification.Name.demoEvent, object: "1")
            NotificationCenter.default.post(name: NSNotification.Name.demoEvent, object: "2")
            NotificationCenter.default.post(name: NSNotification.Name.demoEvent, object: "3")
        }
    }
    
    private func usingOperator() {
        let publisher = NotificationCenter.default.publisher(for: .demoEvent)
        
        
       publisher
            .map ({ ($0.object as! String ) + "1"})
            .filter({ Int($0)! > 11 })
            ///主线程接收
            .receive(on: RunLoop.main)
            ///订阅
            .sink(receiveCompletion: {
                debugPrint(Thread.current)
                debugPrint("completion:\($0)")
            }, receiveValue: {
                debugPrint(Thread.current)
                debugPrint("receiveValue:\($0)")
            })
        .store(in: &cancelables)
        
        
        ///发射元素
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            debugPrint("start emit element")
            
            NotificationCenter.default.post(name: NSNotification.Name.demoEvent, object: "1")
            NotificationCenter.default.post(name: NSNotification.Name.demoEvent, object: "2")
            NotificationCenter.default.post(name: NSNotification.Name.demoEvent, object: "3")
            
        }
        
    }
}


