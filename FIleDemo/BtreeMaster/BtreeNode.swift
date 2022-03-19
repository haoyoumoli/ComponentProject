//
//  BtreeNode.swift
//  BtreeMaster
//
//  Created by apple on 2021/7/13.
//

import Foundation

internal let bTreeNodeSize = 16383


internal final class BTreeNode<Key:Comparable,Value> {
    
  //  typealias Iterator = BTreeIterator<Key, Value>
    typealias Element = (Key,Value)
    typealias Node = BTreeNode<Key, Value>
    
    internal var elements:Array<Element>
    
    internal var children:Array<BTreeNode>
    
    ///B树的节点个数
    internal var count: Int
    
    ///B树的阶
    internal let _order: Int32
    
    internal let _depth:Int32
    
    internal var depth:Int { return numericCast(_depth) }
    
    internal var order: Int { return numericCast(_order) }
    
    internal init(order: Int,elements:Array<Element>,children:Array<BTreeNode>,count: Int) {
        assert(children.count == 0 || elements.count == children.count - 1)
        self._order = numericCast(order)
        self.elements = elements
        self.children = children
        self.count = count
        ///叶子节点的深度是0
        self._depth = (children.count == 0 ? 0 : children[0]._depth + 1)
        assert(children.firstIndex(where: { $0._depth + (1 as Int32) != self._depth}) == nil)
    }
}


//MARK: Convenience initializers
extension BTreeNode {
    static var defaultOrder: Int {
        return Swift.max(bTreeNodeSize / MemoryLayout<Element>.stride, 8)
    }
    
    convenience init(order: Int = Node.defaultOrder) {
        self.init(order: order, elements: [], children: [], count: 0)
    }
    
    internal convenience init(left:Node, separator:(Key,Value), right: Node) {
        assert(left.order == right.order)
        assert(left.depth == right.depth)
        self.init(order: left.order, elements: [separator], children: [left,right], count: left.count + 1 + right.count)
    }
    
    ///使用某个树创建新的树
    internal convenience init(node: BTreeNode, slotRange:CountableRange<Int>) {
        if node.isLeaf {
            let elements = Array(node.elements[slotRange])
            self.init(order: node.order, elements: elements, children: [], count: elements.count)
        }
        else if slotRange.count == 0 {
            let n = node.children[slotRange.lowerBound]
            self.init(order: n.order, elements: n.elements, children: n.children, count: n.count)
        }
        else {
            let elements = Array(node.elements[slotRange])
            let children = Array(node.children[slotRange.lowerBound ... slotRange.upperBound])
            let count = children.reduce(elements.count) { $0 + $1.count}
            self.init(order:node.order, elements: elements, children: children, count: count)
        }
    }
}

//MARK: Uniqueness
extension BTreeNode {
    @discardableResult
    func makeChildUnique(_ index:Int) -> BTreeNode {
        guard !isKnownUniquelyReferenced(&children[index]) else { return children[index] }
        let clone = children[index].clone()
        children[index] = clone
        return clone
    }
    
    func clone() ->BTreeNode {
        return BTreeNode(order: order, elements: elements, children: children, count: count)
    }
}

//MARK: Basic limits and properties
extension BTreeNode {
    ///最大的分支数
    internal var maxChildren: Int { return order }
    
    ///最小的分支数(阶数的一半向上取整)
    internal var minChildren: Int { return (maxChildren + 1) / 2 }
    
    ///最大关键字个数
    internal var maxKeys: Int { return maxChildren - 1 }
    
    ///最小关键字个数
    internal var minKeys: Int { return minChildren - 1}
    
    ///是否为叶子节点
    internal var isLeaf:Bool  { return depth == 0 }
    
    ///元素个数是否太少
    internal var isTooSmall: Bool { return elements.count < minKeys }
    
    ///元素个数是否太多
    internal var isTooLarge: Bool { return elements.count > maxKeys }
    
    ///树是否平衡
    internal var isBanlanced: Bool { return elements.count >= minKeys && elements.count <= maxKeys }
}

//MARK: Sequence

extension BTreeNode {
    var isEmpty: Bool { return count == 0}
    
//    func makeIterator() -> IteratorProtocol {
//
//    }
    
    func forEach(_ body:(Element) throws -> Void)  rethrows {
        if isLeaf {
            for element in elements {
                try body(element)
            }
        }
        else {
            for i in 0..<elements.count {
                try children[i].forEach(body)
                try body(elements[i])
            }
            try children[elements.count].forEach(body)
        }
    }
    
    @discardableResult
    func forEach(_ body:(Element) throws -> Bool) rethrows -> Bool {
        if isLeaf {
            for element in elements {
                guard try body(element) else {
                    return false
                }
            }
        }
        else {
            for i in 0..<elements.count {
                guard try children[i].forEach(body) else { return false}
                guard try body(elements[i]) else { return false }
                
            }
            guard try children[elements.count].forEach(body) else { return false}
        }
        return true
    }
}


//MARK: Slots
extension BTreeNode {
    internal func setElement(inSlot slot:Int, to element: Element) -> Element {
        let old = elements[slot]
        elements[slot] = element
        return old
    }
    
    internal func insert(_ element: Element,inSlot slot:Int) {
        elements.insert(element, at: slot)
        count += 1
    }
    
    internal func append(_ element: Element) {
        elements.append(element)
        count += 1
    }
    
    @discardableResult
    internal func remove(slot: Int) -> Element {
        count -= 1
        return elements.remove(at: slot)
    }
    
    @inline(__always)
    internal func slot(of key:Key,choosing selector: BTreeKeySelector = .first) -> (match:Int?,descend:Int) {
        switch selector {
        case .first,.any:
            var start = 0
            var end = elements.count
            while start < end {
                let mid = start + (end - start) / 2
                if elements[mid].0 < key {
                    start = mid + 1
                } else {
                    end = mid
                }
            }
            return (start < elements.count && elements[start].0 == key ? start : nil,start)
        case .last:
            var start = -1
            var end = elements.count - 1
            while  start < end {
                let mid = start + (end - start + 1) / 2
                if elements[mid].0 > key {
                    end = mid - 1
                } else {
                    start = mid
                }
            }
            return (start >= 0 && elements[start].0 == key ? start : nil,start + 1)
            
        case .after:
            var start = 0
            var end = elements.count
            while start < end {
                let mid = start + (end - start) / 2
                if elements[mid].0 <= key {
                    start = mid + 1
                }
                else {
                    end = mid
                }
            }
            return (start < elements.count ? start : nil, start)
            
        }
    }
    
    internal func slot(atOffset offset: Int) -> (index:Int, match:Bool , offset: Int) {
        assert(offset >= 0 && offset <= count)
        if offset == count {
            return (index:elements.count,match:isLeaf,offset: count)
        }
        if isLeaf {
            return (offset,true,offset)
        }
        else if offset <= count / 2 {
            var p = 0
            for i in 0..<children.count - 1 {
                let c = children[i].count
                if offset == p + c {
                    return (index: i ,match: true , offset: p + c)
                }
                if offset < p + c {
                    return (index: i , match:false , offset: p + c)
                }
                
                p += (c + 1)
            }
            let c = children.last!.count
            precondition(count == p + c,"Invalid B-Tree")
            return (index: children.count - 1,match:false, offset:count)
        }
        
        var p = count
        for i in (1 ..< children.count).reversed() {
            let c = children[i].count
            if offset == p - (c + 1) {
                return (index: i - 1 , match: true , offset: offset)
            }
            if offset > p - (c + 1) {
                return (index:i , match: false ,offset:p)
            }
            p -= c + 1
        }
        let c = children.first!.count
        precondition(p - c == 0,"Invalid B-Tree")
        return (index:0,match:false,offset:c)
    }
    
    internal func offset(ofSlot slot: Int) -> Int {
        let c = elements.count
        assert( slot >= 0  && slot <= count)
        if isLeaf {
            return slot
        }
        
        if slot == c {
            return count
        }
        
        if slot <= c / 2 {
            return children[0...slot].reduce(slot) { $0 + $1.count}
         }
        
        return count - children[slot + 1...c].reduce(c - slot) { $0 + $1.count }
    }
    
    internal func contains(_ key:Key,choosing selector: BTreeKeySelector) -> Bool {
        let firstKey = elements.first!.0
        let lastKey = elements.last!.0
        if key < firstKey {
            return false
        }
        if key == firstKey && selector == .first {
            return false
        }
        
        if key > lastKey {
            return false
        }
        
        if key == lastKey && (selector == .last || selector == .after) {
            return false
        }
        return true
    }
}

//MARK: Lookups
extension BTreeNode {
    var first: Element? {
        var node = self
        while let child = node.children.first {
            node = child
        }
        return node.elements.first
    }
    
    var last: Element? {
        var node = self
        while let child = node.children.last {
            node = child
        }
        return node.elements.last
    }
}


//MARK: Splitting
internal struct BTreeSplinter<Key:Comparable,Value> {
    let separator: (Key,Value)
    let node: BTreeNode<Key,Value>
}

extension BTreeNode {
    typealias Splinter = BTreeSplinter<Key,Value>
    
    internal func split() -> Splinter {
        assert(isTooLarge)
        return split()
    }
    
    internal func split(at median:Int) -> Splinter {
        let count = elements.count
        let separator = elements[median]
        let node = BTreeNode(node: self, slotRange: median + 1 ..< count)
        elements.removeSubrange(median ..< count)
        if isLeaf {
            self.count = median
        }
        else {
            children.removeSubrange(median + 1 ..< count + 1)
            self.count = median + children.reduce(0, { $0 + $1.count})
        }
        assert(node.depth == self.depth)
        return Splinter(separator: separator, node: node)
    }
    
    internal func insert(_ splinter: Splinter, inSlot slot: Int) {
        elements.insert(splinter.separator, at: slot)
        children.insert(splinter.node, at: slot + 1)
    }
}

//MARK: Removal

extension BTreeNode {
    internal func fixDeficiency(_ slot: Int) {
        assert(!isLeaf && children[slot].isTooSmall)
        if slot > 0 && children[slot - 1].elements.count > minKeys {
            
        }
    }
    
    internal func rotateRight(_ slot: Int) {
        assert(slot > 0)
        makeChildUnique(slot)
        makeChildUnique(slot - 1)
        children[slot].elements.insert(elements[slot - 1], at: 0)
        
    }
}

//MARK: Join

extension BTreeNode {
    
    func swapContents(with other: Node) {
        precondition(self._depth == other._depth)
        precondition(self._order == other._order)
        swap(&self.elements, &other.elements)
        swap(&self.children, &other.children)
        swap(&self.count,&other.count)
    }
    
    
    internal func shiftSlots(separator: Element,node: BTreeNode,target: Int) -> Splinter? {
        assert(self.depth == node.depth)
        let forward = target > self.elements.count
        let delta = abs(target - self.elements.count)
        if delta == 0 {
            return Splinter(separator: separator, node: node)
        }
        
        let lc = self.elements.count
        let rc = node.elements.count
        
        if (forward && delta >= rc + 1) || (!forward && delta >= lc + 1) {
            //将整个右节点融化成self
            self.elements.append(separator)
            self.elements.append(contentsOf: node.elements)
            self.children.append(contentsOf: node.children)
            node.elements = []
            node.children = []
            self.count += 1 + node.count
            return nil
        }
        
        let resp: Element
        if forward {
            // Transfer slots from right to left
            assert(lc + delta < self.order)
            assert(delta <= rc)
            
            resp = node.elements[delta - 1]
            
            self.elements.append(separator)
            self.elements.append(contentsOf: node.elements.prefix(delta - 1))
            self.count += delta
            
            if !self.isLeaf {
                let children = node.children.prefix(delta)
                let dc = children.reduce(0) { $0 + $1.count}
                self.children.append(contentsOf: children)
                self.count += dc
                
                node.children.removeFirst()
                node.count -= dc
            }
        }
        else {
            // Transfer slots from left to right
            assert(rc + delta < node.order)
            assert(delta <= rc)
            
            resp = self.elements[lc - delta]
            node.elements.insert(separator, at: 0)
            node.elements.insert(contentsOf: self.elements.suffix(delta - 1), at: 0)
            node.count += delta
            
            self.elements.removeSubrange(lc - delta ..< lc)
            self.count -= delta
            
            if !self.isLeaf {
                let children = self.children.suffix(delta)
                let dc = children.reduce(0) { $0 + $1.count }
                node.children.insert(contentsOf: children, at: 0)
                node.count += dc
                
                self.children.removeSubrange(lc + 1 - delta ..< lc + 1)
                self.count -= dc
            }
        }
        
        if node.children.count == 1 {
            return Splinter(separator: resp, node: node.makeChildUnique(0))
        }
        
        return Splinter(separator: resp, node: node)
    }
    
    internal static func
    join(left: BTreeNode,separator: (Key,Value), right:BTreeNode) -> BTreeNode {
        precondition(left.order == right.order)
        
        let order = left.order
        let depthDelta = left.depth - right.depth
        let append = depthDelta >= 0
        
        ///树干
        let stock = append ? left : right
        
        ///子孙
        let scion = append ? right : left
        
        var path = [stock]
        var node = stock
        let c = scion.count
        for _ in 0 ..< abs(depthDelta) {
            node.count += c + 1
            node = node.makeChildUnique(append ? node.children.count - 1 : 0)
            path.append(node)
        }
        
        if !append { node.swapContents(with: scion) }
        assert(node.depth == scion.depth)
        let slotCount = node.elements.count + 1 + scion.elements.count
        let target = slotCount < order ? slotCount : slotCount / 2
        var splinter = node.shiftSlots(separator: separator, node: scion, target: target)
        if splinter != nil {
            assert(splinter!.node.isBanlanced)
            path.removeLast()
            while let s = splinter, !path.isEmpty {
                let node = path.removeLast()
                node.insert(s, inSlot: append ? node.elements.count : 0)
                splinter = node.isTooLarge ? node.split() : nil
            }
            if let s = splinter {
                return BTreeNode(left: stock, separator: s.separator, right: s.node)
            }
        }
        return stock
        
    }
}
