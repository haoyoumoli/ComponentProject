//
//  ViewController.swift
//  OptimizeCollectionDemo
//
//  Created by apple on 2021/7/6.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btreeTest()
                
        // Do any additional setup after loading the view.
    }
    
    func btreeTest() {
        let date = Date()
        var set = BTree<Int>()
        for i in (1...4_000_000) {
            set.insert(i)
        }
        //debugPrint(set)
        
//        let evenMembers = set.reversed().lazy.filter {
//            $0 % 2 == 0
//        }.map {
//            "\($0)"
//        }.joined(separator: ",")
        
        //debugPrint(evenMembers)
        
        debugPrint("\(Date().timeIntervalSince(date))")
    }
    
    func sortedArrTest() {
        let data = (1...20).shuffled()
        debugPrint(data)
        var sortedArray = SortedArray<Int>.init()
        for i in data {
            _ = sortedArray.insert(i)
        }
        debugPrint(sortedArray)
    }
    
    func redBlackTree2Test() {
        var set = RedBlackTree2<Int>()
        for i in (1...20).shuffled() {
            set.insert(i)
        }
        
        debugPrint(set)
    }
    
    func orderedSetTest() {
        var set = OrderedSet<Int>()
        set.insert(9)
        set.insert(8)
        set.insert(7)
        
        
        let copy = set
        set.insert(6)
        
        debugPrint(set)
        debugPrint(set.contains(7))
        debugPrint(set.reduce(0, +))
        debugPrint(copy)
    }
    
    func redblackTreeDemo2() {
        var set = RedBlackTree<Int>.empty
        let values = (1...20).shuffled()
        debugPrint(values)
        for i in values {
            set.insert(i)
        }
        debugPrint(set)
        
        let result = set.lazy.filter{ $0 % 2 == 0}.map { "\($0)"}.joined(separator: ",")
        debugPrint(result)
    }
    
    func redblackTreeDemo1() {
    
        let emptyTree = RedBlackTree<Int>.empty
        debugPrint(emptyTree)
        
        let tinyTree = RedBlackTree<Int>.node(.black, 42, .empty, .empty)
        debugPrint(tinyTree)
        
        let smallTree = RedBlackTree<Int>
            .node(.black, 2,
                  .node(.red, 1, .empty, .empty),
                  .node(.red, 3, .empty, .empty))
        debugPrint(smallTree)
        
        let bigTree = RedBlackTree<Int>
            .node(.black, 9,
                  .node(.red, 5,.node(.black, 1,.empty,.node(.red, 4, .empty, .empty)), .node(.black, 8, .empty, .empty)), .node(.red, 12,
                                                                                                                                 .node(.black, 11, .empty, .empty), .node(.black, 16, .node(.red, 14, .empty, .empty), .node(.red, 17, .empty, .empty))))
        debugPrint(bigTree)
    }
}

