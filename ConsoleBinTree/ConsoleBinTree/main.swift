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
    
    typealias LevelNode = (node: TreeNode?, level:Int)
    typealias LevelIndexVal = (val: String, level: Int, index: Int)
    typealias NodeIndexed = (node: TreeNode, index: Int, indexLeftChild: Int?, indexRightChild: Int?, level: Int)
    
    func inOrderTrav() -> [LevelNode] {
        var stack = [LevelNode]()
        var res = [LevelNode]()
        var node: LevelNode = (self, 0)
        var level = 0
        while true {
            while node.node != nil {
                stack.append(node)
                node = (node.node?.left, node.level + 1)
            }
            if stack.isEmpty {
                break
            }
            node = stack.popLast()!
            res.append(node)
            node = (node.node?.right, node.level+1)
        }
        return res
    }
    
    func levelIndexVal(_ nodes: [LevelNode]) -> [LevelIndexVal] {
        var vals: [LevelIndexVal] = nodes.map({ (String($0.node!.val), $0.level, 0) })
        var index = 0
        for i in vals.indices {
            let val = vals[i]
            vals[i].index = index
            index += val.val.count + 1
        }
        return vals
    }
    
    func levelStrs(_ vals: [LevelIndexVal]) -> [String] {
        var maxLevel = 0
        for Val in vals {
            if Val.level > maxLevel {
                maxLevel = Val.level
            }
        }
        
        var strs = Array(repeating: "", count: maxLevel+1)
        for (val, level, index) in vals {
            let spaceCount = index-strs[level].count
            assert(spaceCount >= 0)
            let spaces = String(repeating: " ", count: max(0, spaceCount))
            strs[level].append(spaces)
            strs[level].append(val)
        }
        
        return strs
    }
    
    func debugPrintSimple() {
        let vals = levelIndexVal(inOrderTrav())
        
        guard !vals.isEmpty else {
            print("empty tree")
            return
        }
        
        for str in levelStrs(vals) {
            print(str)
        }
        
        print("")
    }
    
    func indexedNodes(_ nodes: [LevelNode]) -> [NodeIndexed] {
        var idxNodes: [NodeIndexed] = nodes.map({ ($0.node!, 0, nil, nil, $0.level) })
        for i in idxNodes.indices {
            let node = idxNodes[i]
            idxNodes[i].index = i
            if let left = node.node.left {
                idxNodes[i].indexLeftChild = idxNodes.firstIndex(where: { $0.node === left })
            }
            if let right = node.node.right {
                idxNodes[i].indexRightChild = idxNodes.lastIndex(where: { $0.node === right})
            }
        }
        return idxNodes
    }
    
    
    /// [from, to]
    /// - Parameters:
    ///   - ch: 需要重复插入的字符
    ///   - strArr: 字符串数组
    ///   - arrIdx: 需要修改的字符串在数组中的索引
    ///   - from: 需要修改的字符串开始下标
    ///   - to: 需要修改的字符串结束下标 (包含to)
    func insert(_ ch: Character, _ strArr: inout [String], arrIdx: Int, from: Int, to: Int) {
        if strArr[arrIdx].count <= to {
            strArr[arrIdx].append(String(repeating: " ", count: to - strArr[arrIdx].count + 1))
        }
        let str = strArr[arrIdx]
        
        let idxFrom = str.index(strArr[arrIdx].startIndex, offsetBy: from)
        let idxTo = str.index(strArr[arrIdx].startIndex, offsetBy: to)
        
        let replacing = String(repeating: ch, count: to-from+1)
        strArr[arrIdx].replaceSubrange(idxFrom...idxTo, with: replacing)
    }
    
    func linkedLevelStrs(_ nodes: [LevelNode]) -> [String] {
        let vals = levelIndexVal(nodes)
        var levelStrs = levelStrs(vals)
        var lines = Array(repeating: "", count: levelStrs.count)
        let idxNodes = indexedNodes(nodes)

        for idxNode in idxNodes {
            
            let nodeVal = vals[idxNode.index]
            let nodeLevel = vals[idxNode.index].level
            
                
            if let idxRC = idxNode.indexRightChild {
                let rcVal = vals[idxRC]
                let rcCenterIdx = rcVal.index + rcVal.val.count / 2
                let nodeRight = nodeVal.index + nodeVal.val.count
                insert("─", &levelStrs, arrIdx: nodeLevel, from: nodeRight, to: rcCenterIdx-1)
                insert("┐", &levelStrs, arrIdx: nodeLevel, from: rcCenterIdx, to: rcCenterIdx)
                insert("│", &lines, arrIdx: nodeLevel, from: rcCenterIdx, to: rcCenterIdx)
            }
            
            if let idxLC = idxNode.indexLeftChild {
                let lcVal = vals[idxLC]
                let lcCenterIdx = lcVal.index + lcVal.val.count / 2
                
                insert("┌", &levelStrs, arrIdx: nodeLevel, from: lcCenterIdx, to: lcCenterIdx)
                insert("─", &levelStrs, arrIdx: nodeLevel, from: lcCenterIdx+1, to: nodeVal.index-1)
                insert("│", &lines, arrIdx: nodeLevel, from: lcCenterIdx, to: lcCenterIdx)
            }
        }
        
        for i in levelStrs.indices.reversed() {
            levelStrs.insert(lines[i], at: i+1)
        }
        
        return levelStrs
    }
    
    func debugPrintLinked() {
        let nodes = inOrderTrav()
        
        guard !nodes.isEmpty else {
            print("empty tree")
            return
        }
        
        for str in linkedLevelStrs(nodes) {
            print(str)
        }
        
        print("")
    }
}

for str in [
    "{1,#,2,#,3}",
    "{1,#,2,3}",
    "{41,22,632,1,31,51,721}",
] {
    let node = TreeNode(str)
    print(str)
    node.debugPrintSimple()
    node.debugPrintLinked()
}


