//
//  Btree.swift
//  BtreeMaster
//
//  Created by apple on 2021/7/13.
//

import Foundation


/// When the tree contains multiple elements with the same key, you can use a key selector to specify
/// which matching element you want to work with.
public enum BTreeKeySelector {
    /// Look for the first element that matches the key.
    ///
    /// Insertions with `.first` insert the new element before existing matches.
    /// Removals remove the first matching element.
    case first

    /// Look for the last element that matches the key.
    ///
    /// Insertions with `.last` insert the new element after existing matches.
    /// Removals remove the last matching element.
    case last

    /// Look for the first element that has a greater key.
    ///
    /// For insertions and removals, this works the same as `.last`.
    case after

    /// Accept any element that matches the key.
    /// This can be faster when there are lots of duplicate keys: the search may stop before reaching a leaf node.
    ///
    /// (This may also happen for distinct keys, but since the vast majority of elements are stored in leaf nodes,
    /// its effect is not very significant.)
    case any
}

public struct Btree<Key:Comparable,Value> {
    
    public typealias Element = (Key,Value)
    internal typealias Node = BTreeNode<Key,Value>
    
    internal var root:Node
    
    internal init(_ root:Node) {
        self.root = root
    }
    
//    public init() {
//        self.init(order: <#T##Int#>)
//    }
    
    public init(order:Int) {
        self.root = Node(order:order)
    }
    
}


extension BTreeNode {
    internal func edit(descend: (Node) -> Int?, ascend: (Node, Int) -> Void) {
        guard let slot = descend(self) else { return }
        do {
            let child = makeChildUnique(slot)
            child.edit(descend: descend, ascend: ascend)
        }
        ascend(self, slot)
    }
}
