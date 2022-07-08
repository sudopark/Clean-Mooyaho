//
//  EnvironmentStorageImple.swift
//  Local
//
//  Created by sudo.park on 2022/07/03.
//

import Foundation
import Extensions


public class EnvironmentStorageImple: EnvironmentStorage {
    
    let userDefatult: UserDefaults
    private let keyPrefix: String
    
    public init(_ userDefatult: UserDefaults, keyPrefix: String) {
        self.userDefatult = userDefatult
        self.keyPrefix = keyPrefix
    }
}


extension EnvironmentStorageImple {
    
    private func keyWithPrefix(_ key: String) -> String {
        return "\(self.keyPrefix)_\(key)"
    }
    
    public func read<T>(_ key: String) throws -> T? where T : Decodable {
        let key = self.keyWithPrefix(key)
        switch T.self {
        case is Bool.Type,
            is Int.Type,
            is Float.Type,
            is Double.Type,
            is String.Type:
            return self.userDefatult.value(forKey: key) as? T

        default:
            return try self.userDefatult.string(forKey: key)
                .flatMap { $0.data(using: .utf8) }
                .flatMap {
                    try JSONDecoder().decode(T.self, from: $0)
                }
        }
    }
    
    public func write<T>(_ key: String, value: T) throws where T : Encodable {
        let key = self.keyWithPrefix(key)
        switch value {
        case let bool as Bool: self.userDefatult.set(bool, forKey: key)
        case let int as Int: self.userDefatult.set(int, forKey: key)
        case let float as Float: self.userDefatult.set(float, forKey: key)
        case let double as Double: self.userDefatult.set(double, forKey: key)
        case let string as String: self.userDefatult.set(string, forKey: key)
        default:
            let data = try JSONEncoder().encode(value)
            guard let stringValue = String(data: data, encoding: .utf8) else {
                throw RuntimeError("write data to environment storage failed, key: \(key), value: \(value)")
            }
            self.userDefatult.set(stringValue, forKey: key)
        }
    }
    
    public func update<T>(_ key: String, _ mutating: (T) -> T) throws where T : Codable {
        guard let oldValue: T = try self.read(key) else {
            throw RuntimeError("update data to environment storage: value not exists for: \(key)")
        }
        let newValue = mutating(oldValue)
        try self.write(key, value: newValue)
    }
    
    public func remove(_ key: String) throws {
        let key = self.keyWithPrefix(key)
        self.userDefatult.removeObject(forKey: key)
    }
    
    public func clearAll() {
        let storedDataKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let shouldRemoveKeys = storedDataKeys.filter { $0.starts(with: self.keyPrefix) }
        shouldRemoveKeys.forEach {
            try? self.remove($0)
        }
    }
}
