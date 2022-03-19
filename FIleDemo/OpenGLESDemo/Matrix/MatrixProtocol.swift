//
//  MatrixProtocol.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/8/5.
//

import Foundation

//MARK: - 核心接口
protocol MatrixProtocol: CustomStringConvertible {
    associatedtype T
    
    var rows:Int  { get }
    
    var cols:Int  { get }
    
    subscript(at row:Int,_ col:Int) -> T {
        get set
    }
}


//MARK: - 方便存取器
extension MatrixProtocol {
    
    mutating func setValuesWithArray( _ arr:[T]) -> Bool  {
        guard arr.count == rows * cols else {
            return false
        }
       
        for i in 0..<rows {
            for j in 0..<cols {
               self[at: i, j] = arr[i * cols + j]
            }
        }
        return true
    }
    
    func getValues() -> [T] {
        var result = [T]()
        for i in 0..<rows {
            for j in 0..<cols {
                result.append(self[at: i, j])
            }
        }
        return result
    }
}

//MARK: - 边界检查
extension MatrixProtocol {
    func containsIndex(row:Int,col:Int) -> Bool {
        return (row < rows && row >= 0) &&
            (col >= 0 && col < cols)
    }
}

//MARK: - 格式化字符串

fileprivate extension String {
    func appendSpace(count:Int) -> String {
        var spaces = ""
        for _ in 0..<count {
            spaces.append(" ")
        }
        return self + spaces
    }
}

extension MatrixProtocol {
    var description: String {
        
        ///存储每一列的字符
        var colStrs:[[String]] = .init(repeating: [], count: cols)
        
        ///存储每一列字符的最大长度
        var colStrMaxCounts:[Int] = .init(repeating: 0, count: cols)
        
        for j in 0..<cols {
            for i in 0..<rows {
                let item = "\(self[at: i, j]) "
                let count = item.count
                colStrs[j].append(item)
                if count > colStrMaxCounts[j] {
                    colStrMaxCounts[j] = count
                }
            }
        }
        
        ///格式化
        for j in 0..<cols {
            for i in 0..<rows {
                colStrs[j][i] = colStrs[j][i].appendSpace(count: colStrMaxCounts[j] - colStrs[j][i].count)
            }
        }
        
        /// 格式输出
        var result = ""
        for i in 0..<rows {
            for j in 0..<cols {
                result.append(colStrs[j][i])
            }
            result.append("\n")
        }
        return result
    }
}
