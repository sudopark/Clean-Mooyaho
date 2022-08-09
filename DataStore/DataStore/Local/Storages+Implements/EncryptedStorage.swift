//
//  EncryptedStorage.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import KeychainSwift

import Domain


enum EncryptedStorageError: Error {
    case unsupportType
    case saveFail
    case encodeFail(_ reason: Error)
    case decodeFail(_ reason: Error)
}

enum EncrytedDataKeys: String {
    case auth
}

public protocol EncryptedStorage: Sendable {
    
    func setupSharedGroup(_ identifier: String)
    
    func save<V>(_ key: String, value: V) -> Result<Void, Error>
    
    func fetch<V>(_ key: String) -> Result<V?, Error>
    
    func delete(_ key: String) -> Bool
}


extension KeychainSwift: @unchecked Sendable {  }

public final class EncryptedStorageImple: EncryptedStorage {
    
    private let keychain: KeychainSwift
    
    public init(identifier prefix: String) {
        self.keychain = KeychainSwift(keyPrefix: prefix)
    }
}


extension EncryptedStorageImple {
    
    public func setupSharedGroup(_ identifier: String) {
        self.keychain.accessGroup = identifier
    }
    
    public func save<V>(_ key: String, value: V) -> Result<Void, Error> {
        
        switch value {
        case let bool as Bool:
            return self.keychain.set(bool, forKey: key).asVoidResult()
            
        case let string as String:
            return self.keychain.set(string, forKey: key).asVoidResult()
            
        case let data as Data:
            return self.keychain.set(data, forKey: key).asVoidResult()
            
        default:
            assert(false, "unsupported type: \(value)")
            return .failure(EncryptedStorageError.unsupportType)
        }
    }
    
    public func fetch<V>(_ key: String) -> Result<V?, Error> {
        
        switch V.self {
        case is Bool.Type:
            return (self.keychain.getBool(key) as? V).asResult()
            
        case is String.Type:
            return (self.keychain.get(key) as? V).asResult()
            
        case is Data.Type:
            return (self.keychain.getData(key) as? V).asResult()
            
        default:
            return .failure(EncryptedStorageError.unsupportType)
        }
    }
    
    public func delete(_ key: String) -> Bool {
        return self.keychain.delete(key)
    }
}

private extension Bool {
    
    func asVoidResult(_ falseError: Error = EncryptedStorageError.saveFail) -> Result<Void, Error> {
        return self ? .success(()) : .failure(falseError)
    }
}

private extension Optional {
    
    func asResult() -> Result<Self, Error> {
        return .success(self)
    }
}


extension EncryptedStorage {
    
    func saveEncodable<E: Encodable>(_ key: String, value: E) -> Result<Void, Error> {
        do {
            let data = try JSONEncoder().encode(value)
            return self.save(key, value: data)
        } catch let error {
            return .failure(EncryptedStorageError.encodeFail(error))
        }
    }
    
    func fetchDecodable<D: Decodable>(_ key: String) -> Result<D?, Error> {
        
        let fetchData: Result<Data?, Error> = self.fetch(key)
        let thenDecode: (Data?) -> Result<D?, Error> = { data in
            guard let data = data else { return .success(nil) }
            do {
                let model = try JSONDecoder().decode(D.self, from: data)
                return .success(model)
                
            } catch let error {
                return .failure(EncryptedStorageError.decodeFail(error))
            }
        }
        
        return fetchData
            .flatMap(thenDecode)
    }
}
