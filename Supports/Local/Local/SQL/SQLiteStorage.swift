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
