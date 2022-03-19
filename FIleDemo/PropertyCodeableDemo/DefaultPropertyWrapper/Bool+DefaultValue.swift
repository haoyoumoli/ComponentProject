//
//  Bool+DefaultWrapper.swift
//  PropertyCodeableDemo
//
//  Created by apple on 2021/5/17.
//

import Foundation

//MARK: -
///为Bool类型添加多种默认值
extension Bool {
    enum False: DefaultValue {
        static let defaultValue = false
    }
    
    enum True: DefaultValue {
        static let defaultValue = true
    }
}



/**
 为bool值添加多种赋值方式,
 例如:
 1 -> true, 0 -> false
 'true'(大小写无关) -> true , 'false'(大小写无关) -> false
 'yes' -> true, 'no' -> false
 */
extension KeyedDecodingContainer {
    func decode(
        _ type:Default<Bool.False>.Type,
        forKey key:Key) throws -> Default<Bool.False> {
    
         var v = try decodeIfPresent(type, forKey: key) ?? Default.init(wrappedValue: Bool.False.defaultValue)
        
        ///解析string 和 int 类型 看看是否有为 true的可能
        if v.wrappedValue == Bool.False.defaultValue {
            if var strV = (try? decodeIfPresent(String.self, forKey: key)) {
                strV = strV.lowercased()
                switch strV {
               
                case "true","yes","1":
                    v.wrappedValue = true
                default:
                    break
                }
                return v
            }
            
            if let intV = (try? decodeIfPresent(Int8.self, forKey: key)),
               intV == 1 {
                v.wrappedValue = true
            }
        }
        return v
    }
}


extension KeyedDecodingContainer {
    func decode(
        _ type:Default<Bool.True>.Type,
        forKey key:Key) throws -> Default<Bool.True> {
    
         var v = try decodeIfPresent(type, forKey: key) ?? Default.init(wrappedValue: Bool.True.defaultValue)
        
        ///解析string 和 int 类型, 看看是否有为 false 的可能
        if v.wrappedValue == Bool.True.defaultValue {
            if var strV = (try? decodeIfPresent(String.self, forKey: key)) {
                strV = strV.lowercased()
                switch strV {
                case "false","no","0":
                    v.wrappedValue = false
                default:
                    break
                }
                return v
            }
            
            if let intV = (try? decodeIfPresent(Int8.self, forKey: key)),
               intV == 0 {
                v.wrappedValue = false
            }
        }
        return v
    }
}



