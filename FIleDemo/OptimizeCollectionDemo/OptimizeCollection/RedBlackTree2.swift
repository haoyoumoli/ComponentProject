//
//  RedBlack2.swift
//  OptimizeCollectionDemo
//
//  Created by apple on 2021/7/7.
//

import Foundation

public struct RedBlackTree2<Element:Comparable> {
    
    class Node {
        var color:Color
        var value:Element
        var left: Node?
        var right: Node?
        var mutationCount:Int64 = 0
        
        init(_ color:Color,_ value:Element,_ left:Node?,_ right:Node?) {
            self.color = color
            self.value = value
            self.left = left
            self.right = right
        }
    }
    
    fileprivate var root:Node? = nil
}

extension RedBlackTree2.Node {
    func forEach(_ body:(Element) throws -> Void) rethrows {
        try left?.forEach(body)
        try body(value)
        try right?.forEach(body)
    }
}

extension RedBlackTree2 {
    func forEach(_ body:(Element) throws -> Void) rethrows {
        try root?.forEach(body)
    }
}

extension RedBlackTree2 {
    public func contains(_ element:Element) -> Bool {
        var node = root
        while let n = node {
            if n.value < element {
                node = n.right
            }
            else if n.value < element {
                node = n.left
            }
            else {
                return true
            }
        }
        return false
    }
}


extension RedBlackTree2:CustomStringConvertible {
    private func diagram<E>(for node:RedBlackTree2<E>.Node?,_ top:String = "",_ root:String = "" , _ bottom:String = "") -> String {
        guard let node = node else {
            return root + "•\n"
        }
        
        if node.left == nil && node.right == nil {
            return root + "\(node.color.symbol)\(node.value)\n"
        }
        
        return diagram(for: node.right, top + "    ", top + "┌───", top + "│   ")
            + root + "\(node.color.symbol)\(node.value)\n"
            + diagram(for: node.left,bottom + "│   ", bottom + "└───", bottom + "    ")
    }
    
    public var description: String {
        return diagram(for: root)
    }
}


extension RedBlackTree2.Node {
    func clone() -> Self {
        return RedBlackTree2.Node.init(color,value,left,right) as! Self
    }
}


extension RedBlackTree2 {
    
    fileprivate mutating func makeRootUnique() -> Node? {
        ///注意这里的拆包写法
        ///“let 绑定将作为根节点的新的引用存在，因此 isKnownUniquelyReferenced 将永远返回 false。这会将写时复制优化破坏殆尽。”
        if root != nil , false == isKnownUniquelyReferenced(&root) {
            root = root!.clone()
        }
        return root
    }
}

extension RedBlackTree2.Node {
    fileprivate func makeLeftUnique() -> RedBlackTree2<Element>.Node? {
        if left != nil , isKnownUniquelyReferenced(&left) {
            left = left!.clone()
        }
        return left
    }
    
    fileprivate func makeRightUnique() -> RedBlackTree2<Element>.Node? {
        if right != nil , isKnownUniquelyReferenced(&right) {
            right = right!.clone()
        }
        return right
    }
}


extension RedBlackTree2 {
    @discardableResult
    public mutating func insert(_ element:Element) ->
    (inserted:Bool,memberAfterInsert:Element) {
        guard let root = makeRootUnique() else {
            self.root = Node(.black,element,nil,nil)
            return (true,element)
        }
        
        defer {
            root.color = .black
        }
        return root.insert(element)
    }
}


extension RedBlackTree2.Node {
    @discardableResult
    public func insert(_ element:Element) ->
    (inserted:Bool,memberAfterInsert:Element) {
        mutationCount += 1
        if element < self.value {
            if let next = makeLeftUnique() {
                let result = next.insert(element)
                if result.inserted { self.balance() }
                return result
            }
            else {
                self.left = .init(.red, element, nil, nil)
                return (true,element)
            }
        }
        else if element > self.value {
            if let next = makeRightUnique() {
                let result = next.insert(element)
                if result.inserted { self.balance() }
                return result
            } else {
                self.right = .init(.red, element, nil, nil)
                return (true,element)
            }
        }
        
        return (false,self.value)
        
    }
    
    func balance() {
        if self.color == .red { return }
        if left?.color == .red {
            if left?.left?.color == .red {
                let l = left!
                let ll = l.left!
                swap(&self.value,&l.value)
                (self.left,l.left,l.right,self.right) = (ll,l.right,self.right,l)
                (self.color,l.color,ll.color) = (.red,.black,.black)
                return
            }
            
            if left?.right?.color == .red {
                let l = left!
                let lr = l.right!
                swap(&self.value,&lr.value)
                (l.right,lr.left,lr.right,self.right) = (lr.left,lr.right,self.right,lr)
                (self.color,l.color,lr.color) = (.red,.black,.black)
                return
            }
        }
        
        if right?.color == .red {
            if right?.left?.color == .red {
                let r = right!
                let rl = r.left!
                swap(&self.value,&rl.value)
                (self.left,rl.left,rl.right,r.left) = (rl,self.left,rl.left,rl.right)
                (self.color,r.color,rl.color) = (.red,.black,.black)
                return
            }
            
            if right?.right?.color == .red {
                let r = right!
                let rr = r.right!
                swap(&self.value,&r.value)
                (self.left,r.left,r.right,self.right) = (r,self.left,r.left,rr)
                (self.color,r.color,rr.color) = (.red,.black,.black)
                return
            }
        }
    }
}

private struct Weak<Wrapped:AnyObject> {
    weak var value:Wrapped?
    
    init(_ value:Wrapped) {
        self.value = value
    }
}


extension RedBlackTree2 {
    public struct Index {
        fileprivate weak var root: Node?
        fileprivate let mutaionCount:Int64?
        
        fileprivate var path:[Weak<Node>]
        
        fileprivate init(root:Node?,path:[Weak<Node>]) {
            self.root = root
            self.path = path
            self.mutaionCount = root?.mutationCount
        }
    }
    
    public var startIndex:Index {
        var path = [Weak<Node>]()
        var node = root
        while let n = node {
            path.append(Weak(n))
            node = n.left
        }
        return Index(root: root, path: path)
    }
    
    
    public var endIndex: Index {
        return Index(root: root, path: [])
    }
}


extension RedBlackTree2.Index {
    fileprivate func isValid(for root:RedBlackTree2<Element>.Node?) -> Bool {
        return self.root === root && self.mutaionCount == root?.mutationCount
    }
    
    fileprivate static func validate(_ left:RedBlackTree2<Element>.Index,_ right:RedBlackTree2<Element>.Index) -> Bool {
        return left.root === right.root
            && left.mutaionCount == right.mutaionCount
            && left.mutaionCount == left.root?.mutationCount
    }
}


extension RedBlackTree2 {
    public subscript(_ index:Index) -> Element {
        precondition(index.isValid(for: root))
        return index.path.last!.value!.value
    }
}

extension RedBlackTree2.Index {
    fileprivate var current:RedBlackTree2<Element>.Node? {
        guard let ref = path.last else { return nil }
        return ref.value!
    }
}

///索引比较
extension RedBlackTree2.Index: Comparable {
    public static func < (lhs: RedBlackTree2<Element>.Index, rhs: RedBlackTree2<Element>.Index) -> Bool {
        precondition(RedBlackTree2<Element>.Index.validate(lhs, rhs))
        switch (lhs.current,rhs.current) {
        case let (a?,b?):
            return a.value < b.value
        case (nil,_):
            return false
        default:
            return true
        }
    }
    
    public static func ==(left:RedBlackTree2<Element>.Index,right:RedBlackTree2<Element>.Index) -> Bool {
        precondition(RedBlackTree2<Element>.Index.validate(left, right))
        return left.current === right.current
    }
}


///索引步进
extension RedBlackTree2 {
    public func formIndex(after index:inout Index) {
        precondition(index.isValid(for: root))
        index.formSuccessor()
    }
        
    public func index(after index:Index) -> Index {
        var result = index
        self.formIndex(after: &result)
        return result
    }
}

extension RedBlackTree2.Index {
    ///后继
    mutating func formSuccessor() {
        guard let node = current else {
            preconditionFailure()
        }
        if var n = node.right {
            path.append(Weak(n))
            while let next = n.left {
                path.append(Weak(next))
                n = next
            }
        }
        else {
            path.removeLast()
            var n = node
            while let parent = self.current {
                if parent.left === n  { return }
                n = parent
                path.removeLast()
            }
        }
    }
}



///前驱
extension RedBlackTree2.Index {
    mutating func
    formPredecessor() {
        let current = self.current
        precondition(current != nil || root != nil )
        ///左子树的的最右子树
        if var n = (current == nil ? root: current!.left) {
            path.append(Weak(n))
            while let next = n.right {
                n = next
            }
        }
        else {
            ///没有左子树,找其父节点
            path.removeLast()
            var n = current
           
            while let parent = self.current {
                if parent.right === n { return }
                n = parent
                path.removeLast()
            }
        }
    }
}


extension RedBlackTree2 {
    public func formIndex(before index: inout Index) {
        precondition(index.isValid(for: root))
        index.formPredecessor()
    }
    
    public func index(before index:Index) -> Index {
        var result = index
        self.formIndex(before: &result)
        return result
    }
}

///移除索引验证
extension RedBlackTree2 {
    public struct Iterator:IteratorProtocol {
        let tree: RedBlackTree2
        var index: RedBlackTree2.Index
        
        init (_ tree:RedBlackTree2) {
            self.tree = tree
            self.index = tree.startIndex
        }
        
        public mutating func next() -> Element? {
            if index.path.isEmpty { return nil }
            defer {
                index.formSuccessor()
            }
            return index.path.last!.value!.value
        }
    }
}

extension RedBlackTree2 {
    public func makeIterator() -> Iterator {
        return Iterator(self)
    }
}

extension RedBlackTree2: Sequence,BidirectionalCollection {} 
