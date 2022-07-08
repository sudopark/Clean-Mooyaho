//
//  SQLiteStorageImple.swift
//  Local
//
//  Created by sudo.park on 2022/07/03.
//

import Foundation

import SQLiteService


// MARK: - SQLiteStorageImple

public final class SQLiteStorageImple: SQLiteStorage {
    
    public struct Configuration {
        let dbPath: String
        let version: Int
        let closeWhenDeinit: Bool
        
        public init(
            dbPath: String,
            version: Int,
            closeWhenDeinit: Bool = true
        ) {
            self.dbPath = dbPath
            self.version = version
            self.closeWhenDeinit = closeWhenDeinit
        }
    }
    
    private let configuration: Configuration
    private let sqliteService: SQLiteService
    
    public init(_ configuration: Configuration) {
        self.configuration = configuration
        self.sqliteService = .init()
    }
    
    deinit {
        guard self.configuration.closeWhenDeinit == true else { return }
        self.sqliteService.close()
    }
}


extension SQLiteStorageImple {
    
    public func open() async throws {
        return try await self.sqliteService.async.open(path: self.configuration.dbPath)
    }
    
    public func close() async throws {
        return try await self.sqliteService.async.close()
    }
    
    public func run<T>( _ execute: @escaping (DataBase) throws -> T) async throws -> T {
        return try await self.sqliteService.async.run(execute: execute)
    }
    
    public func run<T>(_ type: T.Type,
                       _ execute: @escaping (DataBase) throws -> T) async throws -> T {
        return try await self.sqliteService.async.run(type, execute: execute)
    }
}

