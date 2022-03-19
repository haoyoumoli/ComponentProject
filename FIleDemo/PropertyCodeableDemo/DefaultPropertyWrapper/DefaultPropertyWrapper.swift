//
//  DefaultValue.swift
//  PropertyCodeableDemo
//
//  Created by apple on 2021/5/17.
//

//参考链接地址:
//https://blog.csdn.net/sinat_35969632/article/details/109635022


import Foundation

protocol DefaultValue {
    associatedtype Value: Decodable
    static var defaultValue: Value { get }
}

//MARK: -
@propertyWrapper
struct Default<T: DefaultValue> {
    var wrappedValue:T.Value
}

extension Default: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = (try? container.decode(T.Value.self)) ?? T.defaultValue
    }
}

//MARK: -
extension KeyedDecodingContainer {
    func decode<T>(
        _ type:Default<T>.Type,
        forKey key:Key) throws -> Default<T> where T: DefaultValue {
    
        try decodeIfPresent(type, forKey: key) ?? Default.init(wrappedValue: T.defaultValue)

    }
}
