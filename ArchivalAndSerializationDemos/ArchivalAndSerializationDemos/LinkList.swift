//
//  LinkList.swift
//  ArchivalAndSerializationDemos
//
//  Created by apple on 2022/3/11.
//

import Foundation

public class LinkListNode<Value> {
    
    let value:Value
    public  init(value:Value) {
        self.value = value
    }
    public var next:LinkListNode? = nil
    
    public var hasNext:Bool {
        return next != nil
    }
    
    public var last:LinkListNode {
        var p:LinkListNode = self
        while p.hasNext {
            p = p.next!
        }
        return p
    }
}

 extension LinkListNode:CustomStringConvertible {
    public  var description: String {
        var result = "\(value)";
        var p = self.next
        while p != nil {
            result.append("->\(p!.value)")
            p = p!.next
        }
        return result
    }
}

//MARK: -
extension LinkListNode {
    //array 创建链表
    public static func
    from(array:[Value]) -> LinkListNode? {
        var p:LinkListNode? = nil
        var head:LinkListNode? = nil 
        for v in array {
            let l = LinkListNode(value: v)
            if head == nil {
               head = l
               p = head
            } else {
               p!.next = l
               p = p!.next
            }
        }
        return head
    }
    
    ///拷贝链表
    public static func
    from(other: LinkListNode) -> LinkListNode {
        var p1:LinkListNode? = nil
        var p2:LinkListNode? = nil
        let resultHead:LinkListNode = LinkListNode.init(value: other.value)
        p1 = other.next
        p2 = resultHead
        while p1 != nil {
            p2!.next = LinkListNode(value: p1!.value)
            p1 = p1?.next
            p2 = p2?.next
        }
        return resultHead
    }
}


//MARK: - 合并有序链表递归版本
extension LinkListNode {
    
    public static func mergeSortedLinkList(l1:LinkListNode,l2:LinkListNode) -> LinkListNode
    where Value:Comparable {
        return privateMerge(l1: l1, l2: l2)!
        
    }
    
    fileprivate
    static func privateMerge(l1:LinkListNode?,l2:LinkListNode?) -> LinkListNode? where Value:Comparable
    {
        var head:LinkListNode? = nil
        if l1 == nil && l2 != nil {
            return LinkListNode.from(other: l2!)
        } else if l1 != nil && l2 == nil {
            return LinkListNode.from(other: l1!)
        }
        if l1!.value < l2!.value {
            head = LinkListNode(value: l1!.value)
            head?.next = LinkListNode.privateMerge(l1: l1?.next, l2: l2)
        } else {
            head = LinkListNode(value: l2!.value)
            head?.next = LinkListNode.privateMerge(l1: l1, l2: l2?.next)
        }
        
        return head
    }
}


//合并有序链表循环版本
extension LinkListNode {
    
    public static func mergeSortedLinkListIteration(l1:LinkListNode,l2:LinkListNode) -> LinkListNode
    where Value:Comparable {
        var p1:LinkListNode? = l1
        var p2:LinkListNode? = l2
        var p3:LinkListNode? = nil
        var resultHead:LinkListNode? = nil
        while p1 != nil && p2 != nil {
            var next:LinkListNode? = nil
            if p1!.value < p2!.value {
                next = LinkListNode(value: p1!.value)
                p1 = p1?.next
            } else {
                next = LinkListNode(value: p2!.value)
                p2 = p2?.next
            }
            if resultHead == nil {
                resultHead = next
                p3 = resultHead
            } else {
                p3?.next = next
                p3 = p3?.next
            }
        }
        if (p1 != nil) {
            p3?.next = LinkListNode.from(other: p1!)
        } else if (p2 != nil) {
            p3?.next = LinkListNode.from(other: p2!)
        }
        return resultHead!
    }
}
