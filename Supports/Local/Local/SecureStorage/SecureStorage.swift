//
//  SecureStorage.swift
//  Local
//
//  Created by sudo.park on 2022/07/09.
//

import Foundation

import KeychainSwift
import Extensions


public protocol SecureStorage {
    
    func setupSharedGroup(_ identifier: String)
    
    func write<V>(_ key: String, value: V) throws
    
    func read<V>(_ key: String) throws -> V?
    
    func remove(_ key: String) throws
}


public final class SecureStorageImple: SecureStorage {
    
    private let keychain: KeychainSwift
    
    public init(identifier prefix: String) {
        self.keychain = KeychainSwift(keyPrefix: prefix)
    }
    
    public func setupSharedGroup(_ identifier: String) {
        self.keychain.accessGroup = identifier
    }
}


extension SecureStorageImple {
    
    public func write<V>(_ key: String, value: V) throws {
        switch value {
        case let bool as Bool:
            guard self.keychain.set(bool, forKey: key) == true else {
                throw RuntimeError("fail to write bool for key: \(key) at secureStorage")
            }
            
        case let string as String:
            guard self.keychain.set(string, forKey: key) == true else {
                throw RuntimeError("fail to write string for key: \(key) at secureStorage")
            }
            
        case let data as Data:
            guard self.keychain.set(data, forKey: key) == true else {
                throw RuntimeError("fail to write data for key: \(key) at secureStorage")
            }
            
        default:
            throw RuntimeError("unsupport type write called to secure storage: \(value)")
        }
    }
    
    public func read<V>(_ key: String) throws -> V? {
        
        switch V.self {
        case is Bool.Type:
            return self.keychain.getBool(key) as? V
            
        case is String.Type:
            return self.keychain.get(key) as? V
            
        case is Date.Type:
            return self.keychain.getData(key) as? V
            
        default:
            throw RuntimeError("unsupport type read called to secure storage for key: \(key)")
        }
    }
    
    public func remove(_ key: String) throws {
        guard self.keychain.delete(key) == true else {
            throw RuntimeError("remove value at secure storage failed: \(key)")
        }
    }
}
