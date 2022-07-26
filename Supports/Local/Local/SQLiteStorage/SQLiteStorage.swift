//
//  SQLiteStorage.swift
//  Local
//
//  Created by sudo.park on 2022/07/02.
//

import Foundation

import SQLiteService


// NARK: - SQLiteStorage

public protocol SQLiteStorage {
    
    func open() async throws
    
    func close() async throws
    
    func run<T>( _ execute: @escaping (DataBase) throws -> T) async throws -> T
    
    func run<T>(_ type: T.Type, _ execute: @escaping (DataBase) throws -> T) async throws -> T
}


extension String {
    
    public func toArray() throws -> [String] {
        let decoder = JSONDecoder()
        guard let data = self.data(using: .utf8) else { return [] }
        return try decoder.decode([String].self, from: data)
    }
}

extension Array where Element == String {
    
    public func asArrayText() throws -> String {
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8) ?? ""
    }
}
