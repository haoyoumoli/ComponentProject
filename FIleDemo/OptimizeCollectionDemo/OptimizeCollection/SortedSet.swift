//
//  Sorted.swift
//  OptimizeCollectionDemo
//
//  Created by apple on 2021/7/6.
//

import Foundation

public protocol SortedSet:
    BidirectionalCollection,
    CustomStringConvertible
where Element:Comparable
{
    init()
    
    func
    contains(_ element:Element)
    -> Bool
    
    mutating func
    insert(_ newElement:Element)
    -> (inserted:Bool,memberAfterInsert:Element)
}
 
extension SortedSet {
    public var description: String {
        let contents = self.lazy.map({ return "\($0)"}).joined(separator: ",")
        return "[\(contents)]"
    }
}
 
