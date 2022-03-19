//
//  OrderedSet.swift
//  OptimizeCollectionDemo
//
//  Created by apple on 2021/7/9.
//

import Foundation

//MARK: - OrderedSet
private class Canary {}

public struct OrderedSet<Element:Comparable>:SortedSet {
    
    fileprivate var storage = NSMutableOrderedSet()
    fileprivate var canary = Canary()
    
    public init() { }
    
    fileprivate func index(for element:Element) -> Int {
        return storage.index(of: element, inSortedRange: NSRange(0..<storage.count), options: NSBinarySearchingOptions.insertionIndex, usingComparator: OrderedSet.compare)
    }
    
    @discardableResult
    public mutating func insert(_ newElement: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        let index = index(for: newElement)
        if index < storage.count,
           storage[index] as! Element == newElement {
            return (false,storage[index] as! Element)
        }
        makeUnique()
        storage.insert(newElement, at: index)
        return (true,newElement)
    }
    
}

extension OrderedSet {
    func forEach(_ body:(Element) -> Void) {
        storage.forEach{ body($0 as! Element) }
    }
    
    public func contains(_ element: Element) -> Bool {
       // return storage.contains(element) //BUG!
        return storage.contains(element) || index(of: element) != nil
    }
    
    fileprivate static func compare(_ a:Any,_ b:Any) -> ComparisonResult {
        let a = a as! Element,b = b as! Element
        if a < b { return .orderedAscending }
        if a > b { return .orderedDescending }
        return .orderedSame
    }
    
    public func index(of element:Element) -> Int? {
        let index = storage.index(of: element, inSortedRange: NSRange(0..<storage.count), options: NSBinarySearchingOptions.firstEqual, usingComparator: OrderedSet.compare)
        return index == NSNotFound ? nil : index
    }
}

extension OrderedSet: RandomAccessCollection {
    public typealias Index = Int
    public typealias Indices = CountableRange<Int>
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return storage.count }
    
    public subscript(i:Index) -> Element {
        return storage[i] as! Element
    }
    
}
extension OrderedSet {
    fileprivate mutating func makeUnique() {
        if false == isKnownUniquelyReferenced(&canary) {
            storage = storage.mutableCopy() as! NSMutableOrderedSet
            canary = Canary()
        }
    }
}

struct Value {
    let value:Int
    init(_ value:Int) { self.value = value}
    
    static func ==(left:Value,right:Value) -> Bool {
        return left.value == right.value
    }
    
    static func <(left:Value,right:Value) -> Bool {
        return left.value < right.value
    }
}
