//
//  Allgorithm.swift
//  WagesDemo
//
//  Created by apple on 2022/5/20.
//

import Foundation

class Algorithm {
    func start() {
        linkList()
    }
    func linkList() {
        func demo1() {
            let head = ListNode(array: [1,2,3,4,5,6])!
            let p = ListNode.reverseBetween(head, 3, 4)
            debugPrint(p?.toArray())
        }
        
        func demo2() {
            let head = ListNode(array: [1,2,3])!
            let p = ListNode.reverseBetween(head, 3, 3)
            debugPrint(p?.toArray())
        }
        
        func demo3() {
            let head = ListNode(array: [1,2])!
            let p = ListNode.reverseBetween(head, 1, 2)
            debugPrint(p?.toArray())
        }
        //        demo1()
        //        demo2()
        //        demo3()
        
        func demo4() {
            let head = ListNode(array: [1,2,3,4,5])
            let p = ListNode.reverseKGroup(head, 2)
            debugPrint(p?.toArray())
        }
        
        func demo5() {
            let head = ListNode(array: [1,2,3,4,5])
            let p = ListNode.reverseKGroup(head, 3)
            debugPrint(p?.toArray())
        }
        //        demo4()
        //        demo5()
        
        func demoMerge1() {
            let h1 = ListNode(array: [1,2,3])
            let h2 = ListNode(array: [4,5])
            debugPrint(ListNode.Merge(h1, h2)?.toArray())
        }
        
        func demoMerge2() {
            let h1 = ListNode(array: [1,2,3])
            let h2 = ListNode(array: [])
            debugPrint(ListNode.Merge(h1, h2)?.toArray())
        }
        
        func demoMerge3() {
            let h1 = ListNode(array: [])
            let h2 = ListNode(array: [1,2])
            debugPrint(ListNode.Merge(h1, h2)?.toArray())
        }
        
        func demoMerge4() {
            let h1 = ListNode(array: [])
            let h2 = ListNode(array: [])
            debugPrint(ListNode.Merge(h1, h2)?.toArray())
        }
        
        //        demoMerge1()
        //        demoMerge2()
        //        demoMerge3()
        //        demoMerge4()
        
        func demoMergeKList1() {
            let h1 = ListNode(array: [1,2,3])
            let h2 = ListNode(array: [8,9,10])
            let h3 = ListNode(array: [4,5,6])
            let arr:[ListNode?] = [h1,h2,h3]
            debugPrint(ListNode.mergeKLists2(arr)?.toArray())
        }
        // demoMergeKList1()
        
        func demoHasCycle1() {
            let noCycleHead = ListNode(array: [1,2,3,4,5])
            debugPrint(ListNode.hasCycle(noCycleHead))
            
            let cycledHead = ListNode(array: [1,2,3,4,5])
            let lasted = ListNode._getNodeAndAfter(cycledHead, 5)
            lasted.0?.next = cycledHead
            debugPrint(ListNode.hasCycle(cycledHead))
            
        }
        // demoHasCycle1()
        
        
        func demoCycleEntryNode() {
            let node1 = ListNode(val: 1, next: nil )
            let node2 = ListNode(val: 2, next: nil )
            let node3 = ListNode(val: 3, next: nil )
            let node4 = ListNode(val: 4, next: nil )
            let node5 = ListNode(val: 5, next: nil )
            let node6 = ListNode(val: 6, next: nil )
            let node7 = ListNode(val: 7, next: nil )
            node1.next = node2
            node2.next = node3
            node3.next = node4
            node4.next = node5
            node5.next = node6
            node6.next = node7
            //构建环
            node7.next = node4
            
            let result  = ListNode.EntryNodeOfLoop(node1)
            debugPrint("入口节点:\(result?.val)")
        }
        //demoCycleEntryNode()
        
        func demoFindKthTrail() {
            let head = ListNode(array: [1,2,3,4,5,6])
            let last2Tail = ListNode.FindKthToTail(head, 2)
            debugPrint(last2Tail?.val == 5)
            let last8Tail = ListNode.FindKthToTail(head, 8)
            debugPrint(last8Tail?.val == nil )
            let last6Tail = ListNode.FindKthToTail(head, 6)
            debugPrint(last6Tail?.val == 1)
        }
        // demoFindKthTrail()
        
        
        func demoRemoveNthFromEnd1() {
            let head = ListNode(array: [1,2,3,4,5])
            let newHead = ListNode.removeNthFromEnd(head, 1)
            debugPrint(newHead?.toArray())
        }
        func demoRemoveNthFromEnd2() {
            let head = ListNode(array: [1,2,3,4,5])
            let newHead = ListNode.removeNthFromEnd(head, 3)
            debugPrint(newHead?.toArray())
        }
        func demoRemoveNthFromEnd3() {
            let head = ListNode(array: [1,2,3,4,5])
            let newHead = ListNode.removeNthFromEnd(head, 5)
            debugPrint(newHead?.toArray())
        }
        func demoRemoveNthFromEnd4() {
            let head = ListNode(array: [1,2,3,4,5])
            let newHead = ListNode.removeNthFromEnd(head, 0)
            debugPrint(newHead?.toArray())
        }
        
        //        demoRemoveNthFromEnd1()
        //        demoRemoveNthFromEnd2()
        //        demoRemoveNthFromEnd3()
        //        demoRemoveNthFromEnd4()
        
        
        func demoFindFirstCommonNode1() {
            let node1 = ListNode(val: 1, next: nil )
            let node2 = ListNode(val: 2, next: nil )
            let node3 = ListNode(val: 3, next: nil )
            let node4 = ListNode(val: 4, next: nil )
            let node5 = ListNode(val: 5, next: nil )
            let node6 = ListNode(val: 6, next: nil )
            let node7 = ListNode(val: 7, next: nil )
            
            node1.next = node2
            node2.next = node3
            node3.next = node6
            node6.next = node7
            
            node4.next = node5
            node5.next = node6
            
            let common = ListNode.FindFirstCommonNode(node1, node4)
            debugPrint(common?.val == 6)
        }
        
        /// demoFindFirstCommonNode1()
        
        func demoAddInList() {
            let head1 = ListNode(array: [9,3,7])
            let head2 = ListNode(array: [6,3])
            let result = ListNode.addInList(head1, head2)
            debugPrint(result?.toArray())
        }
        //demoAddInList()
        
        func demoInSortList() {
            let head1 = ListNode(array: [5,4,3,2,1])
            debugPrint(ListNode.sortInList2(head1)?.toArray())
        }
        //demoInSortList()
        
        func demoIsPail() {
            let head1 = ListNode(array: [1,2,1])
            let head2 = ListNode(array: [1,2,2,1])
            
            let head3 = ListNode(array: [])
            debugPrint(ListNode.isPail(head1) == true)
            debugPrint(ListNode.isPail(head2) == true)
            debugPrint(ListNode.isPail(head3) == true)
            
            let head4 = ListNode(array: [1,2,3])
            debugPrint(ListNode.isPail(head4) == false)
            
            let head5 = ListNode(array: [1,2,3,2,1])
            debugPrint(ListNode.isPail(head5) == true)
        }
        //  demoIsPail()
        
        func demoIsPail2() {
            let head1 = ListNode(array: [1,2,1])
            let head2 = ListNode(array: [1,2,2,1])
            
            let head3 = ListNode(array: [])
            debugPrint(ListNode.isPail2(head1) == true)
            debugPrint(ListNode.isPail2(head2) == true)
            debugPrint(ListNode.isPail2(head3) == true)
            
            let head4 = ListNode(array: [1,2,3])
            debugPrint(ListNode.isPail2(head4) == false)
            
            let head5 = ListNode(array: [1,2,3,2,1])
            debugPrint(ListNode.isPail2(head5) == true)
        }
        // demoIsPail2()
        func demoOddEvenList() {
            let head1 = ListNode(array: [1,2,3,4,5,6])
            debugPrint(ListNode.oddEvenList(head1)?.toArray())
            let head2 = ListNode(array: [1,4,6,3,7])
            debugPrint(ListNode.oddEvenList(head2)?.toArray())
            let head3 = ListNode(array: [])
            debugPrint(ListNode.oddEvenList(head3)?.toArray())
        }
        // demoOddEvenList()
        
        func demoOddEvenList2() {
            let head1 = ListNode(array: [1,2,3,4,5,6])
            debugPrint(ListNode.oddEvenList2(head1)?.toArray())
            let head2 = ListNode(array: [1,4,6,3,7])
            debugPrint(ListNode.oddEvenList2(head2)?.toArray())
            let head3 = ListNode(array: [])
            debugPrint(ListNode.oddEvenList2(head3)?.toArray())
        }
        
        // demoOddEvenList2()
        
        func demoDeleteDuplicates() {
            let head1 = ListNode(array: [1,1,2,3])
            debugPrint(ListNode.deleteDuplicates(head1)?.toArray())
            let head2 = ListNode(array: [])
            debugPrint(ListNode.deleteDuplicates(head2)?.toArray())
            let head3 = ListNode(array: [1,1,2,2,3])
            debugPrint(ListNode.deleteDuplicates(head3)?.toArray())
            let head4 = ListNode(array: [1,2,3,3,3])
            debugPrint(ListNode.deleteDuplicates(head4)?.toArray())
        }
        // demoDeleteDuplicates()
        
        func demoDeleteAllDuplicates() {
            //            let head1 = ListNode(array: [1,1,2,3])
            //            debugPrint(ListNode.deleteAllDuplicates(head1)?.toArray())
            //            let head2 = ListNode(array: [])
            //            debugPrint(ListNode.deleteAllDuplicates(head2)?.toArray())
            //            let head3 = ListNode(array: [1,1,2,2,3])
            //            debugPrint(ListNode.deleteAllDuplicates(head3)?.toArray())
            //            let head4 = ListNode(array: [1,2,3,3,3])
            //            debugPrint(ListNode.deleteAllDuplicates(head4)?.toArray())
            
            let head5 = ListNode(array: [1,2,3,3,3,4,4,5])
            debugPrint(ListNode.deleteAllDuplicates(head5)?.toArray())
            
            //            let head6 = ListNode(array: [-50,-49,-49,-49,-48,-48,-47,-47,-46,-46,-46,-44,-42,-40,-40,-40,-39,-39,-38,-37])
            //            debugPrint(ListNode.deleteAllDuplicates(head6)?.toArray())
        }
       // demoDeleteAllDuplicates()
        
        
        func demoDeleteAllDuplicates2() {
            let head1 = ListNode(array: [1,1,2,3])
            debugPrint(ListNode.deleteAllDuplicates2(head1)?.toArray())
            let head2 = ListNode(array: [])
            debugPrint(ListNode.deleteAllDuplicates2(head2)?.toArray())
            let head3 = ListNode(array: [1,1,2,2,3])
            debugPrint(ListNode.deleteAllDuplicates2(head3)?.toArray())
            let head4 = ListNode(array: [1,2,3,3,3])
            debugPrint(ListNode.deleteAllDuplicates2(head4)?.toArray())
            
            let head5 = ListNode(array: [1,2,3,3,3,4,4,5])
            debugPrint(ListNode.deleteAllDuplicates2(head5)?.toArray())
        }
        demoDeleteAllDuplicates2()
    }
    
    
}
