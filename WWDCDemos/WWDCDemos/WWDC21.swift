//
//  WWDC21.swift
//  MainProject
//
//  Created by apple on 2022/2/17.
//

import UIKit
//MARK:-

public struct TestType {
    @DefensiveCopying(withoutCopying: UIBezierPath())
    public var path:UIBezierPath
    
    @LateInitialized
    public var string:String
    
    init() {}
}

@propertyWrapper
public struct DefensiveCopying<Value:NSCopying> {
    private var storage: Value
    
    public init(withoutCopying value:Value) {
        debugPrint(#function)
        storage = value
    }
    
    public init(wrappedValue value:Value) {
        self.storage = value.copy() as! Value
    }
    
    public var wrappedValue: Value {
        get { storage }
        set { storage = newValue.copy() as! Value }
    }
}

@propertyWrapper
public struct LateInitialized<Value> {
    private var storage: Value?
    
    public init() {
        storage = nil
    }
    
    public var wrappedValue:Value {
        get {
            guard let value = storage else {
                fatalError("value has not yet been set!")
            }
            return value
        }
        
        set {
            storage = newValue
        }
    }
}

@dynamicMemberLookup
struct GeometricVector<Storage:SIMD> where Storage.Scalar : FloatingPoint {
    private(set) var value:Storage
    
    init(_ value:Storage) {
        self.value = value
    }
    
   /**
    KeyPath<T,V> 只读
    WritableKeyPath<T,V> 可读写
    ReferenceWritableKeyPath<T,V> 引用类型的可读写
    */
   public subscript<T>(dynamicMember keyPath:WritableKeyPath<Storage,T>) -> T {
        get {
            value[keyPath:keyPath]
        }

        set {
            value[keyPath:keyPath] = newValue
        }
    }
}

struct AAA {
    let a1:Double
    let a2:Int
}


struct BBB {
    let b1:Int
    let b2:String
}

//WWraper 具有AAA和BBB的全部属性(只读)
@dynamicMemberLookup
struct WWraper {
    let a:AAA
    let b:BBB
    
    init(a:AAA,b:BBB) {
        self.a = a
        self.b = b
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<AAA,T>) -> T {
        a[keyPath: keyPath]
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<BBB,T>) -> T {
        b[keyPath: keyPath]
    }
    
    
//    subscript(dynamicMember keyPath: KeyPath<AAA,Double>) -> Double {
//        a[keyPath: keyPath]
//    }
//
//    subscript(dynamicMember keyPath: KeyPath<AAA,Int>) -> Int {
//        a[keyPath: keyPath]
//    }
//
//    subscript(dynamicMember keyPath: KeyPath<BBB,Int>) -> Int {
//        b[keyPath: keyPath]
//    }
//
//    subscript(dynamicMember keyPath: KeyPath<BBB,String>) -> String {
//        b[keyPath: keyPath]
//    }
}


struct Smoothie {
    
}

@resultBuilder
enum SmoothieArrayBuilder {
    
    static func buildBlock(_ description:String,_ components: Smoothie...) -> (String,[Smoothie]) {
        return (description,components)
    }
    
    @available(*,unavailable,message: "first statement of SmoothieBuilder must be its description String")
    static func buildBlock(_ components: Smoothie...) -> (String,[Smoothie]) {
        fatalError()
    }
    
    static func buildExpression(_ expression: Smoothie) -> [Smoothie] {
        return [expression]
    }
    
    static func buildExpression(_ expression: Void) -> [Smoothie] {
        return []
    }
    
    //处理 if
    static func buildOptional(_ component: [Smoothie]?) -> [Smoothie] {
        return component ?? []
    }
    
    
    static func buildEither(first component: [Smoothie]) -> [Smoothie] {
        return component
    }
    
    static func buildEither(second component: [Smoothie]) -> [Smoothie] {
        return component
    }
    
}


