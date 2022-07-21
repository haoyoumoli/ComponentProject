//
//  LinkListArgrithom.swift
//  WagesDemo
//
//  Created by apple on 2022/5/20.
//

import Foundation

///牛客网链表算法题

public class ListNode {
    public var val:Int
    public var next:ListNode?
    
    init(val:Int,next:ListNode?) {
        self.val = val
        self.next = next
    }
    
    init?(array:[Int]) {
        if array.count == 0 { return nil }
        self.val = array.first!
        self.next = nil
        var cur:ListNode? = self
        for i in 1..<array.count {
            cur?.next = ListNode(val: array[i], next: nil)
            cur = cur?.next
        }
    }
    
    func toArray() -> [Int] {
        var cur:ListNode? = self
        var result:[Int] = []
        while cur != nil {
            result.append(cur!.val)
            cur = cur!.next
        }
        return result
    }
}

extension ListNode:Hashable {
    public static func == (lhs: ListNode, rhs: ListNode) -> Bool {
        return lhs === rhs
    }
    public func hash(into hasher: inout Hasher) {
        let v = Unmanaged<ListNode>.passUnretained(self).toOpaque()
        hasher.combine(v)
    }
    
}

//mark: - 反转链表
extension ListNode {
    ///反转整个链表
    static  func ReverseList (_ head: ListNode?) -> ListNode? {
        // write code here
        var cur:ListNode? = head
        var pre:ListNode? = nil
        while cur != nil {
            let next = cur?.next
            cur?.next = pre
            pre = cur
            cur = next
        }
        return pre
    }
    
    
    /// 反转链表进阶,可以指定区间, 从1开始计数
    /// - Returns: 返回反转的链表
    static  func reverseBetween ( _ head: ListNode?,  _ m: Int,  _ n: Int) -> ListNode? {
        
        let startAndPre = _getNodeAndPre(head, m)
        
        let endAndAfter = _getNodeAndAfter(head, n)
        
        //反转的节点包含了头结点,需要使用新的反转的头作为返回
        let needUseNewHead = startAndPre.1 == nil
        
        let reversedHead = _reversBetween((startAndPre.0,startAndPre.1), (endAndAfter.0,endAndAfter.1))
        if (needUseNewHead) {
            return reversedHead
        }
        return head
    }
    
    /**
     * 代码中的类名、方法名、参数名已经指定，请勿修改，直接返回方法规定的值即可
     *
     * @param head ListNode类
     * @param k int整型
     * @return ListNode类
     */
    static func reverseKGroup ( _ head: ListNode?,  _ k: Int) -> ListNode? {
        var newHead:ListNode? = nil
        var p = head
        //记录反转之后链表的尾节点
        var pre:ListNode? = nil
        var startAndPre:(ListNode?,ListNode?)? = nil
        var endAndAfter: (ListNode?,ListNode?)? = nil
        
        
        while p != nil {
            //优化:用每次从链表头获取节点位置
            startAndPre = (_getNodeAndPre(p, 1).0,pre)
            endAndAfter = _getNodeAndAfter(p,k)
            
            //如果长度不够了直接退出
            if startAndPre?.0 == nil || endAndAfter?.0 == nil {
                break
            }
            
            //获取一段反转后的链表
            let reversed = _reversBetween(startAndPre!, endAndAfter!)
            //反转的节点包含了头结点,需要使用新的反转的头作为返回
            if startAndPre?.1 == nil && newHead == nil {
                newHead = reversed
            }
            p = endAndAfter?.1
            //反转之后startAndPre.0 是反转之后链表的尾节点
            pre = startAndPre?.0
            
        }
        if newHead == nil {
            return head
        }
        return newHead
    }
    
    //合并两个已经排序的链表
    static func Merge ( _ pHead1: ListNode?,  _ pHead2: ListNode?) -> ListNode? {
        var p1:ListNode? = pHead1
        var p2:ListNode? = pHead2
        //记录合并后的链表的末尾
        var cur:ListNode? = nil
        //记录合并后新的头节点
        var newHead:ListNode? = nil
        while p1 != nil || p2 != nil {
            if p1 != nil && p2 != nil  {
                //获取比较小的节点
                var smaller:ListNode? = nil
                if p1!.val < p2!.val {
                    smaller = p1
                    p1 = p1?.next
                } else {
                    smaller = p2
                    p2 = p2?.next
                }
                //构造合并后的链表
                if newHead == nil {
                    newHead = smaller
                    cur = newHead
                } else {
                    cur?.next = smaller
                    cur = cur?.next
                }
            } else if p1 != nil  {
                if newHead == nil {
                    newHead = p1
                } else {
                    cur?.next = p1
                }
                break
            } else if p2 != nil {
                if newHead == nil {
                    newHead = p2
                } else {
                    cur?.next = p2
                }
                break
            }
        }
        return newHead
    }
    
    ///合并多个已经排序的链表
    ///最直接的方式,遍历,一个一个合并
    ///效率低,每次都需要遍历已经合并的结果,增加了额外的遍历次数
    ///运行超时😂
    static func mergeKLists ( _ lists: [ListNode?]) -> ListNode? {
        if lists.isEmpty { return nil }
        var merged = lists[0]
        for i in stride(from: 1, to: lists.count, by: 1) {
            merged = ListNode.Merge(merged, lists[i])
        }
        return merged
    }
    
    ///两两分别合并,可以极大地减少总的遍历次数
    static func mergeKLists2 ( _ lists: [ListNode?]) -> ListNode? {
        let count = lists.count
        if count == 0 { return nil }
        if count == 1 { return lists[0] }
        if count == 2 { return ListNode.Merge(lists[0], lists[1]) }
        var newLists:[ListNode?] = []
        var i = 0
        while i < count {
            if i + 1 <= count - 1 {
                newLists.append(ListNode.Merge(lists[i], lists[i + 1]))
            } else {
                newLists.append(lists[i])
            }
            i += 2
        }
        return mergeKLists2(newLists)
    }
    
    ///两两合并,可以极大地减少总的遍历次数
    ///传递索引,不使用存储中间数组
    ///代码很节俭,但是对于我来说不太好理解
    static func mergeKLists3 ( _ lists: [ListNode?]) -> ListNode? {
        return _mergeKLists3(list: lists, left: 0, right: lists.count - 1)
    }
    
    ///判断链表中是否有环
    ///使用快慢指针法
    static func hasCycle ( _ head: ListNode?) -> Bool {
        var faster:ListNode? = head?.next
        var slower:ListNode? = head
        while faster != nil || slower != nil {
            if (faster === slower) {
                return true
            }
            faster = faster?.next?.next
            slower = slower?.next
        }
        return false
    }
    /// 链表中环的入口节点
    /// 同样是使用快慢指针, 使用快慢指针可以检测出链表的环
    /// 但是如何确定入口节点我还不知道,看了题解才了解
    /// 另外使用hash法,可以比较简单的获取入口节点,每次遍历将节点放入hash set中
    /// 第一个重复的节点就是入口节点, 不过这种方法控件复杂度O(n),时间复杂度没有明显提升
    /// 故做简单了解,拓展思路
    static func EntryNodeOfLoop ( _ pHead: ListNode?) -> ListNode? {
        var faster:ListNode? = pHead
        var slower:ListNode? = pHead
        while faster != nil || pHead != nil {
            
            faster = faster?.next?.next
            slower = slower?.next
            
            if faster === slower {
                break
            }
        }
        if faster == nil || slower == nil {
            //链表中没有环
            return nil
        }
        //这一次fast从头节点一步一步的走,直到追slow指针,再度相遇就是入口节点
        faster = pHead
        while faster !== slower {
            faster = faster?.next
            slower = slower?.next
        }
        return faster
    }
    
    ///链表中倒数最后K个节点
    static func FindKthToTail ( _ pHead: ListNode?,  _ k: Int) -> ListNode? {
        if k < 1 { return nil }
        var aft:ListNode? = pHead
        for _ in 1..<k {
            aft = aft?.next
        }
        //链表长度不够k
        if aft == nil { return nil }
        var pre = pHead
        while aft != nil {
            aft = aft?.next
            if aft == nil {
                break
            }
            pre = pre?.next
            
        }
        return pre
    }
    ///给定一个链表，删除链表的倒数第 n 个节点并返回链表的头指针
    static func removeNthFromEnd ( _ head: ListNode?,  _ n: Int) -> ListNode? {
        if n < 1 { return head }
        var end:ListNode? = head
        /// 1是有效索引
        /// 首先移动end指针,使其距离头部k个距离
        for _ in stride(from: 1, to:n , by: 1) {
            end = end?.next
        }
        ///链表的长度小于n, 不合法,返回nil
        if end == nil { return nil }
        var cur:ListNode? = head
        var curPre:ListNode? = nil
        while end != nil {
            end = end?.next
            if end == nil {
                break
            }
            curPre = cur
            cur = cur?.next
        }
        //要删除的节点恰好是头节点
        if curPre == nil {
            let newHead = cur?.next
            cur?.next = nil
            return newHead
        }
        //删除节点
        curPre?.next = cur?.next
        cur?.next = nil
        return head
    }
    
    /// 输入两个无环的单向链表，找出它们的第一个公共结点，如果没有公共节点则返回空。
    /// 要求:空间复杂度O(1),时间复杂度O(n)
    /// 这个算法时间复杂度O(n^2)
    static func FindFirstCommonNode ( _ pHead1: ListNode?,  _ pHead2: ListNode?) -> ListNode? {
        var cur1 = pHead1
        var cur2 = pHead2
        ///双层循环,暴力求解
        while cur1 != nil {
            while cur2 != nil {
                if cur1 === cur2 {
                    return cur1
                }
                cur2 = cur2?.next
            }
            cur2 = pHead2
            cur1 = cur1?.next
        }
        return nil
    }
    
    ///这个算法时间复杂度O(n+m)
    static func FindFirstCommonNode2( _ pHead1: ListNode?,  _ pHead2: ListNode?) -> ListNode? {
        var cur1 = pHead1
        var cur2 = pHead2
        while cur1 !== cur2 {
            ///构造虚拟的环
            cur1 = (cur1 == nil ? pHead1 : cur1?.next)
            cur2 = (cur2 == nil ? pHead2 : cur2?.next)
        }
        return cur1
    }
    
    //假设链表中每一个节点的值都在 0 - 9 之间，那么链表整体就可以代表一个整数。
    //给定两个这种链表，请生成代表两个整数相加值的结果链表。
    static func addInList( _ head1: ListNode?,  _ head2: ListNode?) -> ListNode? {
        var arr1:[Int] = []
        var arr2:[Int] = []
        var resultArr:[Int] = []
        var cur1 = head1
        var cur2 = head2
        //将两个链表的元素分别添加的数据中,方便索引
        while cur1 != nil || cur2 != nil {
            if cur1 != nil {
                arr1.append(cur1!.val)
            }
            if cur2 != nil {
                arr2.append(cur2!.val)
            }
            cur1 = cur1?.next
            cur2 = cur2?.next
        }
        let last1 = arr1.count - 1
        let last2 = arr2.count - 1
        //进位
        var carry = 0
        var idx = 0
        //处理每一位相加
        while last1 - idx >= 0 && last2 - idx >= 0 {
            var sum = arr1[last1 - idx] + arr2[last2 - idx] + carry
            if sum >= 10 {
                sum -= 10
                carry = 1
            } else {
                carry = 0
            }
            resultArr.append(sum)
            idx += 1
        }
        //处理剩下的位
        if last1 > last2 {
            while last1 - idx >= 0 {
                var sum = arr1[last1 - idx] + carry
                if sum >= 10 {
                    sum -= 10
                    carry = 1
                } else {
                    carry = 0
                }
                resultArr.append(sum)
                idx += 1
            }
        } else {
            while last2 - idx >= 0 {
                var sum = arr2[last2 - idx] + carry
                if sum >= 10 {
                    sum -= 10
                    carry = 1
                } else {
                    carry = 0
                }
                resultArr.append(sum)
                idx += 1
            }
        }
        if carry > 0 {
            resultArr.append(carry)
        }
        //构造新链表
        idx = resultArr.count - 1
        var newHead:ListNode? = nil
        var cur:ListNode? = nil
        while idx >= 0 {
            let newNode = ListNode(val: resultArr[idx], next: nil)
            if newHead == nil {
                newHead = newNode
                cur = newHead
            } else {
                cur?.next = newNode
                cur = cur?.next
            }
            idx -= 1
        }
        return newHead
    }
    
    ///链表排序,要求事件复杂度O(nLog(n))
    ///冒泡实现 O(n^2) 不符合要求, 这是我最先想到的
    ///运行时间超时
    static func sortInList ( _ head: ListNode?) -> ListNode? {
        var cur = head
        var idx = cur?.next
        while cur != nil {
            while idx != nil {
                if cur!.val > idx!.val
                {
                    let temp = cur!.val
                    cur!.val = idx!.val
                    idx!.val = temp
                }
                idx = idx?.next
            }
            cur = cur?.next
            idx = cur?.next
            
        }
        return head
    }
    
    
    ///使用归并排序
    ///时间复杂度O(nlog(n)) ,空间复杂度O(1)
    ///我也想到了用归并,但是我没有写出来,😭,看了题解
    ///我还想到了用数组暂存所有的链表节点,方便索引,然后用快速排序
    ///但是我也没有写出来,而且这种方式的空间复杂度为O(n).
    ///要复习一下归并排序和快速排序了,😭
    ///感觉好像有点算法思想了? 分解
    static func sortInList2(_  head: ListNode?) -> ListNode? {
        if head == nil || head?.next == nil {
            return head
        }
        var fast = head?.next
        var slow = head
        //定位链表中间节点
        while (fast != nil && fast?.next != nil) {
            slow = slow?.next
            fast = fast?.next?.next
        }
        //先保存中间节点的后继节点
        let temp = slow?.next
        //链表中间断开
        slow?.next = nil
        
        //递归左右两边进行排序
        var left = sortInList(head)
        var right = sortInList(temp)
        //虚假的头节点
        var h:ListNode? = ListNode(val: 0, next: nil)
        let res = h
        //合并left right两个链表
        while left != nil && right != nil {
            if left!.val < right!.val {
                h?.next = left
                left = left?.next
            } else {
                h?.next = right
                right = right?.next
            }
            h = h?.next
        }
        //最后添加没有对比的链表部分
        h?.next = left != nil ? left : right
        return res?.next
    }
    
    /**
     判断链表是否是回文结构
     时间复杂度O(n)
     空间复杂度O(n)
     但是其不破坏链表
     */
    static func isPail ( _ head: ListNode?) -> Bool {
        //暂存数组
        var arr:[ListNode] = []
        var cur = head
        while cur != nil {
            arr.append(cur!)
            cur = cur?.next
        }
        let mid = arr.count >> 1
        var p = mid - 1
        //奇数个的时候,略过中间的
        var q = (arr.count % 2 != 0 ? mid + 1 : mid)
        while p >= 0 && q <= arr.count - 1 {
            if arr[p].val != arr[q].val {
                return false
            }
            p -= 1
            q += 1
        }
        return true
    }
    
    /**
     破坏链表的实现 O(1)空间复杂度
     也有折中的办法, 在找中点时用数组记录头半个链表
     就省去了反转链表的过程空间复杂度O(n/2)
     */
    static func isPail2 ( _ head: ListNode?) -> Bool {
        //1.快慢指针找中点
        var fast = head
        var mid = head
        var half = 0
        while fast != nil && fast!.next != nil {
            mid = mid?.next
            half += 1
            fast = fast?.next?.next
        }
        // var len = (fast == nil) ? (2 * half) : 2 * half + 1
        //2.反转链表
        //奇数时,去除掉中间节点
        if fast != nil {
            mid = mid?.next
        }
        var n = 0
        // new head
        var cur = head
        var newHead:ListNode? = nil
        while n < half {
            let t = cur?.next
            cur?.next = newHead
            newHead = cur
            cur = t
            n += 1
        }
        //3.进行对比
        var p = newHead
        var q = mid
        while p != nil && q != nil {
            if p!.val != q!.val {
                return false
            }
            p = p?.next
            q = q?.next
        }
        
        return true
    }
    
    ///给定一个单链表，请设定一个函数，将链表的奇数位节点和偶数位节点分别放在一起，重排后输出。
    ///注意是节点的编号而非节点的数值。
    ///时间复杂度O(N),空间复杂度O(n)
    static func oddEvenList( _ head: ListNode?) -> ListNode? {
        //奇数位暂存数组
        var oddArr:[ListNode] = []
        //偶数位暂存数组
        var evenArr:[ListNode] = []
        var cur = head
        var idx = 0
        while cur != nil {
            if idx % 2 == 0 {
                evenArr.append(cur!)
            } else {
                oddArr.append(cur!)
            }
            cur = cur?.next
            idx += 1
        }
        cur = evenArr.first
        //重新构造链表
        for i in stride(from: 1, to: evenArr.count, by: 1) {
            cur?.next = evenArr[i]
            cur = cur?.next
        }
        for i in stride(from: 0, to: oddArr.count, by: 1) {
            cur?.next = oddArr[i]
            cur = cur?.next
        }
        //修改最后一个节点next为空,防止出现环
        oddArr.last?.next = nil
        return evenArr.first
    }
    
    ///双指针
    ///时间复杂度O(n),空间复杂度O(1)
    static func oddEvenList2( _ head: ListNode?) -> ListNode? {
        if head == nil {
            return head
        }
        //利用奇数位节点和偶数位节点相邻的特性
        //奇数
        var oddCur = head?.next
        let oddHead = oddCur
        //偶数
        var evenCur = head
        while oddCur != nil && oddCur?.next != nil {
            evenCur?.next = evenCur?.next?.next
            evenCur  = evenCur?.next
            oddCur?.next = oddCur?.next?.next
            oddCur = oddCur?.next
        }
        evenCur?.next = oddHead
        return head
    }
    
    
}


extension ListNode {
    
    static func _mergeKLists3(list:[ListNode?],left:Int,right:Int ) -> ListNode? {
        if left == right {
            return list[left]
        }
        if (left > right) {
            return nil
        }
        let mid = left + ((right - left) >> 1)
        return ListNode.Merge(_mergeKLists3(list: list, left: left, right: mid), _mergeKLists3(list: list, left: mid + 1, right: right))
    }
    
    //获取第m个节点和前一个节点以及是否超出了链表长度
    //注意:head必须是整个链表的头节点
    static func _getNodeAndPre(_ head:ListNode?, _ m:Int) -> (ListNode?,ListNode?){
        var cur = head
        var pre:ListNode? = nil
        for _ in 1..<m {
            pre = cur
            cur = cur?.next
        }
        return (cur,pre)
    }
    //获取第m个节点和后一个节点
    static func _getNodeAndAfter(_ head:ListNode?, _ m:Int) -> (ListNode?,ListNode?){
        var cur = head
        var aft:ListNode? = nil
        for _ in 1..<m {
            cur = cur?.next
        }
        aft = cur?.next
        return (cur,aft)
    }
    
    
    /// 使用起始节点和起始节点的前一个节点, 和终止节点和终止节点的后一个节点反转起始节点到终止节点之间的链表
    /// - Parameters:
    ///   - startAndPre: 起始节点和起始节点的前一个节点
    ///   - endAndAfter: 终止节点和终止节点的后一个节点
    /// - Returns: 返回反转链表的头部
    static func _reversBetween(_ startAndPre:(ListNode?,ListNode?),
                               _ endAndAfter:(ListNode?,ListNode?)) ->  ListNode? {
        var startAndPre = startAndPre
        var cur:ListNode? = startAndPre.0
        //反转后的表头
        var pre:ListNode? = nil
        while cur !== endAndAfter.1 {
            let next = cur?.next
            cur?.next = pre
            pre = cur
            cur = next
        }
        //前节点是空,此时是从0开始
        if startAndPre.1 == nil {
            startAndPre.1 = pre
        } else {
            startAndPre.1?.next = pre
        }
        //链接反转后链表的尾部
        startAndPre.0?.next = endAndAfter.1
        return startAndPre.1
    }
    
    
    //删除有序链表中的重复元素,
    static func deleteDuplicates ( _ head: ListNode?) -> ListNode? {
        let fakeHead:ListNode? = ListNode(val: -1, next: head)
        var cur = head
        var pre = fakeHead
        while cur != nil  {
            if cur?.val == pre?.val {
                pre?.next = cur?.next
            } else {
                pre = pre?.next
            }
            cur = cur?.next
        }
        return fakeHead?.next
    }
    
    //删除有序链表中所有出现一次以上的元素,只保留出现一次的元素
    static func deleteAllDuplicates ( _ head: ListNode?) -> ListNode? {
        let fakeHead:ListNode? = ListNode(val: -1, next: head)
        let fakeHeadPre:ListNode? = ListNode(val: -1, next: fakeHead)
        var cur = head
        var pre = fakeHead
        var prePre = fakeHeadPre
        var hasSamePre = false
        while cur != nil {
            if cur?.val == pre?.val {
                pre?.next = cur?.next
                hasSamePre = true
            } else {
                if hasSamePre {
                    //之前有过相同的说明要删除这个剩下的pre
                    prePre?.next = pre?.next
                    pre = cur
                    //删除了一些相同的元素,清空标记
                    hasSamePre = false
                } else {
                    //继续移动pre 和 preCur
                    prePre = pre
                    pre = pre?.next
                }
            }
            cur = cur?.next
        }
        //循环退出时检查,是否有没删干净
        if hasSamePre {
            prePre?.next = pre?.next
        }
        return fakeHead?.next
    }
    
    static func deleteAllDuplicates2(_ head:ListNode?) -> ListNode? {
        let fakeHead = ListNode(val: -1, next: head)
        var p:ListNode? = fakeHead
        while p?.next != nil && p?.next?.next != nil {
            if p?.next?.val == p?.next?.next?.val {
                let num = p?.next?.val
                while p?.next != nil && p?.next?.next?.val == num {
                    p?.next = p?.next?.next
                }
            } else {
                p = p?.next
            }
        }
        return fakeHead.next
    }
}
