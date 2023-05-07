//
//  TestSQLiteStorage.swift
//  LocalDoubles
//
//  Created by sudo.park on 2022/07/27.
//

import Foundation

import Local


extension SQLiteStorageImple {
    
    private static func testDBPath(_ name: String) -> String {
        return try! FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("\(name).db")
            .path
    }
    
    public static func testStorage(_ name: String) -> SQLiteStorage {
        let path = self.testDBPath(name)
        let configure = SQLiteStorageImple.Configuration(dbPath: path, version: 0, closeWhenDeinit: false)
        return SQLiteStorageImple(configure)
    }
    
    public static func clearStorage(_ name: String) {
        let path = self.testDBPath(name)
        try? FileManager.default.removeItem(atPath: path)
    }
}
