//
//  BTree2.swift
//  OptimizeCollectionDemo
//
//  Created by apple on 2021/7/9.
//

import Foundation

public struct BTree2<Element:Comparable> {
    fileprivate var root:Node
    public init (order:Int) {
        self.root = Node(order: order)
    }
}


extension BTree2 {
    final class Node {
        let order: Int
        var mutationCount: Int64 = 0
        var elementCount:Int = 0
        let elements:UnsafeMutablePointer<Element>
        var children:ContiguousArray<Node> = []
        
        init(order:Int) {
            self.order = order
            self.elements = .allocate(capacity: order)
        }
        
        deinit {
            elements.deinitialize(count: elementCount)
            elements.deallocate()
        }
    }
}

extension BTree2.Node {
    func clone() -> BTree2<Element>.Node {
        let node = BTree2<Element>.Node(order: order)
        node.elementCount = self.elementCount
        node.elements.initialize(from: self.elements, count: self.elementCount)
        if !isLeaf {
            node.children.reserveCapacity(order + 1)
            node.children += self.children
        }
        return node
    }
    
    var isLeaf:Bool {
        return self.children.isEmpty
    }
    
    func split() -> BTree2<Element>.
}
