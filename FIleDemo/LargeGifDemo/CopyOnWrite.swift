//
//  CopyOnWrite.swift
//  LargeGifDemo
//
//  Created by apple on 2022/6/10.
//

import Foundation

public final class Ref<T> {
  var val : T
  init(_ v : T) {val = v}
}

public struct Box<T> {
    var ref : Ref<T>
    init(_ x : T) { ref = Ref(x) }
    var value: T {
        get { return ref.val }
        set {
          if (!isKnownUniquelyReferenced(&ref)) {
            ref = Ref(newValue)
            return
          }
          ref.val = newValue
        }
    }
}


@propertyWrapper
public struct CopyOnWrite<T: Any> {
    public var box: Box<T>
    
    public var wrappedValue: T {
        set {
            box.value = newValue
        }
        get {
            return box.value
        }
       
    }
    
    public init(wrappedValue: T) {
        box = Box(wrappedValue)
    }
}
