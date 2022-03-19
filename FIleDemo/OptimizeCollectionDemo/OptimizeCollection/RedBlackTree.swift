//
//  RBTree.swift
//  OptimizeCollectionDemo
//
//  Created by apple on 2021/7/7.
//

import Foundation

//MARK:- Color

public enum Color {
    case red
    case black
}

extension Color {
    var symbol:String {
        switch self {
        case .red:
            return "□"
        case .black:
            return "■"
        }
    }
}

//MARK: - RedBlackTree

public enum RedBlackTree<Element:Comparable> {
    case empty
    indirect case node(Color,Element,RedBlackTree,RedBlackTree)
}

extension RedBlackTree {
    public func contains(_ element:Element) -> Bool {
        switch self {
        case .empty:
            return false
        case .node(_, element, _, _):
            return true
        case let .node(_, value, left, _) where value > element:
            return left.contains(element)
        case let .node(_, _, _, right):
            return right.contains(element)
        }
    }
    
    func forEach(_ body:(Element) throws -> Void) rethrows {
        switch self {
        
        case .empty:
            break
        case let .node(_, value, left, right):
            try left.forEach(body)
            try body(value)
            try right.forEach(body)
            
        }
    }
}

extension RedBlackTree:CustomStringConvertible {
    public var description: String {
        return self.diagram("", "", "")
    }
    
    ///实现很有意思,要好好研究研究
    /// 输出实例如下:
    //    ┌───□17
    //┌───■16
    //│   └───□14
    //┌───□12
    //│   └───■11
    //■9
    //│   ┌───■8
    //└───□5
    //│   ┌───□4
    //└───■1
    //    └───•
    
    func diagram(_ top:String,_ root:String,_ bottom:String) -> String {
        switch self {
        
        case .empty:
            return root + "•\n"
            
        case let .node(color, value, .empty, .empty):
            return root + "\(color.symbol)\(value)\n"
            
        case let .node(color, value, left, right):
            return
                right.diagram(top + "    ", top + "┌───",  top + "│   ")
                + root
                + "\(color.symbol)\(value)\n"
                + left.diagram(bottom + "│   ", bottom + "└───", bottom + "    ")
        }
    }
    
}


extension RedBlackTree {
    
    public func inserting(_ element:Element) ->(tree:RedBlackTree,existingMember:Element?) {
        let (tree,old) = _inserting(element)
        switch tree {
        case let .node(.red,value,left,right):
            return (.node(.black,value,left,right),old)
        default:
            return(tree,old)
        }
    }
    
    private func _inserting(_ element:Element) -> (tree:RedBlackTree,old:Element?) {
        
        switch self {
        
        ///向空树中添加元素
        case .empty:
            
            return (.node(.red,element,.empty,.empty),nil)
            
        ///树中已经存在这个值
        case let .node(_,value,_,_) where value == element:
            return (self,value)
            
        /// 节点的元素大于要添加的元素
        case let .node(color,value,left,right) where value > element:
            let (l,old) = left._inserting(element)
            if let old = old { return (self,old) }
            return (balanced(color,value,l,right),nil)
            
        case let .node(color,value,left,right):
            let (r,old) = right._inserting(element)
            if let old = old { return (self,old)}
            return (balanced(color, value, left, r),nil)
            
        }
    }
    
    private func balanced(_ color:Color, _ value: Element, _ left:RedBlackTree, _ right:RedBlackTree) -> RedBlackTree {
        switch (color,value,left,right) {
        case let (.black,z,.node(.red,y,.node(.red,x,a,b),c),d):
            return .node(.red, y, .node(.black,x,a,b), .node(.black,z,c,d))
            
        case let (.black,z,.node(.red,x,a,.node(.red, y, b, c)),d):
            return .node(.red, y, .node(.black,x,a,b), .node(.black,z,c,d))
            
        case let (.black,x,a,.node(.red, z, .node(.red, y, b, c), d)):
            return .node(.red, y, .node(.black,x,a,b), .node(.black,z,c,d))
            
        case let (.black,x,a,.node(.red,y,b,.node(.red, z, c, d))):
            return .node(.red, y, .node(.black,x,a,b), .node(.black,z,c,d))
            
        default:
            return .node(color, value, left, right)
        }
    }
    
    
    @discardableResult public mutating
    func insert(_ element:Element)
    -> (inserted:Bool,memberAfterInsert:Element) {
        let (tree,old) = inserting(element)
        self = tree
        return (old == nil,old ?? element)
    }
}


extension RedBlackTree {
    public struct Index {
        fileprivate var value: Element?
    }
}

extension RedBlackTree.Index:Comparable {
    public static func ==(left:RedBlackTree<Element>.Index,right:RedBlackTree<Element>.Index) -> Bool {
        return left.value == right.value
    }
    
    ///nil代表结束索引, 结束索引比其它索引都大
    public static func
    <(left:RedBlackTree<Element>.Index,right:RedBlackTree<Element>.Index) -> Bool {
        if let lv = left.value,let rv = right.value {
            return lv < rv
        }
        
        return left.value != nil
    }
}

extension RedBlackTree {
    func min() -> Element? {
        switch self {
        case .empty:
            return nil
        case let .node(_, value, left, _):
            return left.min() ?? value
        }
    }
    
    func max() -> Element? {
        var node = self
        var maximum:Element? = nil
        while case let .node(_,value,_,right) = node {
            maximum = value
            node = right
        }
        return maximum
    }
}


extension RedBlackTree {
    public var startIndex: Index { return Index(value: self.min())}
    
    public var endIndex: Index { return Index(value: nil)}
    
    public subscript(i:Index) -> Element {
        return i.value!
    }
}

extension RedBlackTree {
  
    ///获取后继几点
    func value(following element:Element) -> (found:Bool,next:Element?) {
        switch self {
        
        case .empty:
            return (false,nil)
            
        case .node(_,element,_, let right):
            return (true,right.min())
            
        case let .node(_,value,left,_) where value > element:
            let v = left.value(following: element)
            return (v.found,v.next ?? value)
        
        case let .node(_,_,_,right):
            return right.value(following: element)
            
        }
    }
    
    public func index(after i:Index) -> Index {
        let v = self.value(following:i.value!)
        precondition(v.found)
        return Index(value: v.next)
    }
    
    
    
    ///获取前驱节点
    func value(preceding element:Element)
    -> (found:Bool,next:Element?) {
        var node = self
        var previous: Element? = nil
        while case let .node(_,value,left,right) = node {
            if value > element {
                node = left
            }
            else if value < element {
                previous = value
                node = right
            }
            else {
                return (true,left.max() ?? previous)
            }
        }
        return (false,previous)
    }
    
    public func index(before i:Index) -> Index {
        if let value = i.value {
            let v = self.value(preceding: value)
            precondition(v.found)
            return Index(value: v.next)
        }
        else{
            return Index(value: max()!)
        }
    }
}


extension RedBlackTree {
    public var count:Int {
        switch self {
        case .empty:
            return 0
        case let .node(_,_,left,right):
            return left.count + 1 + right.count
        }
    }
}


extension RedBlackTree:SortedSet {
    public init() {
        self = .empty
    }
}

extension RedBlackTree:BidirectionalCollection,Collection,Sequence {}
