//
//  LinklistNodeTest.swift
//  ArchivalAndSerializationDemosTests
//
//  Created by apple on 2022/3/11.
//

import XCTest
import ArchivalAndSerializationDemos
class LinkListNodeTests: XCTestCase  {
    
    func testDescription() {
        let l1 = LinkListNode.init(value: 1)
        let l2 = LinkListNode.init(value: 2)
        
        XCTAssertTrue(l1.description == "1", "description 单个元素测试失败")
        
        l1.next = l2
        XCTAssertTrue(l1.description == "1->2", "Description测试失败")
        
    }
    
    func testFromArray() {
        
        let l1 = LinkListNode.from(array: [])
        XCTAssertTrue(l1 == nil, "from(array: []) 测试失败")
        
        
        let l2 = LinkListNode.from(array: [1])!
        XCTAssertTrue(l2.description == "1", "from(array: [1]) 测试失败")
        
        let l3 = LinkListNode.from(array: [1,2])!
        XCTAssertTrue(l3.description == "1->2", "from(array: [1,2]) 测试失败")
    }
    
    
    func testFromOther() {
        let l1 = LinkListNode.from(array: [1,2,3])!
        
        let l2 = LinkListNode.from(other: l1)
        
        var p1:LinkListNode? = l1
        var p2:LinkListNode? = l2
        while p1 != nil && p2 != nil {
           XCTAssertFalse(p1 === p2,"from(other: l1) 测试失败")
            p1 = p1?.next
            p2 = p2?.next
        }
    }
    
    
    func testMergeSortedLinkList() {
        
        let l1 = LinkListNode.from(array: [1,3,5])!
        let l2 = LinkListNode.from(array: [2,4,6,8])!
        
        let l3 = LinkListNode.mergeSortedLinkList(l1: l1, l2: l2)
        
        XCTAssertTrue(l3.description == "1->2->3->4->5->6->8")
    }
    
    func testMergeSortedItLinkListIteration() {
        
        let l1 = LinkListNode.from(array: [1,3,5])!
        let l2 = LinkListNode.from(array: [2,4,5,6,8])!
        
        let l3 = LinkListNode.mergeSortedLinkListIteration(l1: l1, l2: l2)
        
        XCTAssertTrue(l3.description == "1->2->3->4->5->5->6->8")
    }
}
