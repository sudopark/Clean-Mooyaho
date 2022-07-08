//
//  EnvironmentStorage.swift
//  Local
//
//  Created by sudo.park on 2022/07/03.
//

import Foundation


public protocol EnvironmentStorage {
 
    func read<T: Decodable>(_ key: String) throws -> T?
    
    func write<T: Encodable>(_ key: String, value: T) throws
    
    func update<T: Codable>(_ key: String, _ mutating: (T) -> T) throws
    
    func remove(_ key: String) throws
    
    func clearAll()
}
