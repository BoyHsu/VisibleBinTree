//
//  main.swift
//  ConsoleBinTree
//
//  Created by 徐恩 on 2023/4/16.
//

import Foundation

public class TreeNode {
    public var val: Int
    public var left: TreeNode?
    public var right: TreeNode?
    public init(_ val: Int=0, _ left: TreeNode?=nil, _ right: TreeNode?=nil) {
        self.val = val
        self.left = left
        self.right = right
    }
}

extension TreeNode {
    convenience init?(_ str: String) {
        guard !str.isEmpty else { return nil }
        var str = str
        str.remove(at: str.startIndex)
        str.remove(at: str.index(before: str.endIndex))
        var nodes = [TreeNode?]()
        
        for subStr in str.split(separator: ",") {
            if let val = Int(subStr) {
                nodes.append(TreeNode(val))
            } else if subStr == "#" {
                nodes.append(nil)
            }
        }
        
        var idxParent = 0, idxChild = 1
        let count = nodes.count
        while idxChild < count {
            if let node = nodes[idxParent] {
                node.left = nodes[idxChild]
                idxChild += 1
                if idxChild < count {
                    node.right = nodes[idxChild]
                    idxChild += 1
                }
            }
            idxParent += 1
        }
        
        if let root = nodes.first! {
            self.init(root.val, root.left, root.right)
        } else {
            return nil
        }
    }
}

extension TreeNode? {
    func serialize() -> String {
        guard let root = self else { return "" }
        var queue = [root]
        var res = "{"
        var curLevel = "\(root.val)"
        while !queue.isEmpty {
            res.append(contentsOf: curLevel)
            curLevel.removeAll(keepingCapacity: true)
            var nextLevel = [TreeNode]()
            for node in queue {
                if let l = node.left {
                    nextLevel.append(l)
                    curLevel.append(",\(l.val)")
                } else {
                    curLevel.append(",#")
                }
                if let r = node.right {
                    nextLevel.append(r)
                    curLevel.append(",\(r.val)")
                } else {
                    curLevel.append(",#")
                }
            }
            queue = nextLevel
        }
        while res.last?.isWholeNumber != true {
            res.removeLast()
        }
        res.append("}")
        return res
    }
}


extension TreeNode? {
    func debugPrint() {
        guard let self = self else {
            print("empty tree")
            return
        }
        var inOrderTrav = [(level: Int, index: Int, val: String)]()
        typealias Node = (level:Int, node: TreeNode?)
        var stack = [Node]()
        var node: Node = (0, self)
        var level = 0
        while true {
            while node.node != nil {
                stack.append(node)
                node = (node.level + 1, node.node?.left)
            }
            if stack.isEmpty {
                break
            }
            node = stack.popLast()!
            var index = 0
            if let last = inOrderTrav.last {
                index = last.index + last.val.count + 1
            }
            inOrderTrav.append((node.level, index, String(node.node!.val)))
            if node.level > level {
                level = node.level
            }
            node = (node.level+1, node.node?.right)
        }
        
        var strs = Array(repeating: "", count: level+1)
        for (level, index, val) in inOrderTrav {
            let spaceCount = index-strs[level].count
            assert(spaceCount >= 0)
            let spaces = String(repeating: " ", count: max(0, spaceCount))
            strs[level].append(spaces)
            strs[level].append(val)
        }
        for str in strs {
            print(str)
        }
    }
}

TreeNode("{1,#,2,#,3}").debugPrint()
TreeNode("{1,#,2,3}").debugPrint()
TreeNode("{4,2,6,1,3,5,7}").debugPrint()
