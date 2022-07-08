//
//  EnvironmentStorageImpleTests.swift
//  LocalTests
//
//  Created by sudo.park on 2022/07/09.
//

import XCTest

import SQLiteService
import Extensions
import Prelude
import Optics

@testable import Local

class EnvironmentStorageImpleTests: XCTestCase {
    
    private var storage: EnvironmentStorageImple!
    
    override func setUpWithError() throws {
        self.storage = .init(.standard, keyPrefix: "test")
    }
    
    override func tearDownWithError() throws {
        self.storage.clearAll()
        self.storage = nil
    }
    
    private struct Dummy: Codable, Equatable {
        
        enum CodingKeys: String, CodingKey {
            case int
            case some
        }
        
        var int: Int
        var some: String
        
        init(_ int: Int, _ some: String) {
            self.int = int
            self.some = some
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.int = try container.decode(Int.self, forKey: .int)
            self.some = try container.decode(String.self, forKey: .some)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.int, forKey: .int)
            try container.encode(self.some, forKey: .some)
        }
    }
}

extension EnvironmentStorageImpleTests {
    
    func testStorage_writeAndRead() {
        // given
        // when
        try? self.storage.write("boo", value: true)
        try? self.storage.write("int", value: 1)
        try? self.storage.write("double", value: Double(10.00))
        try? self.storage.write("float", value: Float(0.11))
        try? self.storage.write("string", value: "string")
        try? self.storage.write("dummy", value: Dummy(100, "some") )
        
        // then
        let bool: Bool? = try? self.storage.read("boo")
        let int: Int? = try? self.storage.read("int")
        let double: Double? = try? self.storage.read("double")
        let float: Float? = try? self.storage.read("float")
        let string: String? = try? self.storage.read("string")
        let dummy: Dummy? = try? self.storage.read("dummy")
        XCTAssertEqual(bool, true)
        XCTAssertEqual(int, 1)
        XCTAssertEqual(double, 10.00)
        XCTAssertEqual(float, 0.11)
        XCTAssertEqual(string, "string")
        XCTAssertEqual(dummy, .init(100, "some"))
    }
    
    func testStorage_updateValue() {
        // given
        try? self.storage.write("some", value: Dummy(200, "old_value"))
        
        // when
        try? self.storage.update("some") { (dummy: Dummy) -> Dummy in
            return dummy |> \.some .~ "new_value"
        }
        
        // then
        let dummy: Dummy? = try? self.storage.read("some")
        XCTAssertEqual(dummy?.int, 200)
        XCTAssertEqual(dummy?.some, "new_value")
    }
    
    func testStorage_removeValue() {
        // given
        try? self.storage.write("value", value: 100)
        
        // when
        let valueBeforeRemove: Int? = try? self.storage.read("value")
        try? self.storage.remove("value")
        let valueAfterRemove: Int? = try? self.storage.read("value")
        
        // then
        XCTAssertEqual(valueBeforeRemove, 100)
        XCTAssertEqual(valueAfterRemove, nil)
    }
}
