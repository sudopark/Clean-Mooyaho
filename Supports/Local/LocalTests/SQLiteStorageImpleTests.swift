//
//  SQLiteStorageImpleTests.swift
//  LocalTests
//
//  Created by sudo.park on 2022/07/02.
//

import XCTest

import SQLiteService
import Extensions

@testable import Local


class SQLiteStorageImpleTests: XCTestCase {
    
    private var storage: SQLiteStorageImple!
    
    func testDBPath(_ name: String) -> String {
        return try! FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("\(name).db")
            .path
    }
 
    override func setUpWithError() throws {
        let configure = SQLiteStorageImple.Configuration(
            dbPath: self.testDBPath("some"),
            version: 0,
            closeWhenDeinit: false
        )
        self.storage = .init(configure)
    }
    
    override func tearDownWithError() throws {
        self.storage = nil
        try? FileManager.default.removeItem(atPath: self.testDBPath("some"))
    }
}


extension SQLiteStorageImpleTests {
    
    func testStorage_open() async {
        // given
        // when
        let result: Void? = try? await self.storage.open()
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testStorage_close() async {
        // given
        try? await self.storage.open()
        
        // when
        let result: Void? = try? await self.storage.close()
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testStorage_runSaveAndLoad() async {
        // given
        try? await self.storage.open()
        let dummy = User("some")
        
        // when
        try? await self.storage.run { try $0.insertOne(UserTable.self, entity: dummy, shouldReplace: true) }
        let selectQuery = UserTable.selectAll { $0.userID == "some" }
        let user: User? = try? await self.storage.run { try $0.loadOne(selectQuery) }
        
        // then
        XCTAssertEqual(user?.userID, "some")
        XCTAssertNil(user?.name)
    }
}


private extension SQLiteStorageImpleTests {
    
    struct User: RowValueType {
        let userID: String
        let name: String?
        
        init(_ userID: String, _ name: String? = nil) {
            self.userID = userID
            self.name = name
        }
        
        init(_ cursor: CursorIterator) throws {
            self.userID = try cursor.next().unwrap()
            self.name = cursor.next()
        }
    }
    
    class UserTable: Table {
        
        enum Columns: String, TableColumn {
            
            case userID
            case name
            
            var dataType: ColumnDataType {
                switch self {
                case .userID: return .text([.primaryKey(autoIncrement: false), .notNull])
                case .name: return .text([])
                }
            }
        }
        
        typealias EntityType = User
        typealias ColumnType = Columns
        
        static var tableName: String { "users" }
        
        static func scalar(_ entity: User, for column: Columns) -> ScalarType? {
            switch column {
            case .userID: return entity.userID
            case .name: return entity.name
            }
        }
    }
}
