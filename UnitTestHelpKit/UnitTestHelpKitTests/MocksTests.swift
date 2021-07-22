//
//  MocksTests.swift
//  UnitTestHelpKitTests
//
//  Created by ParkHyunsoo on 2021/04/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest
@testable import UnitTestHelpKit


class MocksTests: XCTestCase {
    
    
    func testMock_registerAndResolve() {
        // given
        let mock = Mock()
        
        // when
        mock.register(key: "bar") { "some" }
        
        // then
        let result = mock.bar(0)
        XCTAssertEqual(result, "some")
    }
    
    func testMock_resolveNotRegisteredValue() {
        // given
        let mock = Mock()
        
        // when
        // then
        let result = mock.bar(0)
        XCTAssertEqual(result, nil)
    }
    
    func testMock_whenResolveNotRegisterValueWithDefaultValue_returnDefaultValue() {
        // given
        let mock = Mock()
        
        // when
        // then
        let result = mock.barwithDefault()
        XCTAssertEqual(result, "default value")
    }
    
    func testMock_called() {
        // given
        let mock = Mock()
        var isCalled = false
        
        mock.called(key: "bar") { args in
            if let int = args as? Int, int == 100 {
                isCalled = true
            }
        }
        
        // when
        _ = mock.bar(100)
        
        // then
        XCTAssertEqual(isCalled, true)
    }
    
    func testMock_mockAndClear() {
        // given
        let mock = Mock()
        mock.register(key: "some") { 1 }
        
        // when
        mock.clear(key: "some")
        
        // then
        let resolved = mock.resolve(Int.self, key: "some")
        XCTAssertNil(resolved)
    }
}


extension MocksTests {
    
    class Mock: Mocking {
        
        func bar(_ int: Int) -> String? {
            self.verify(key: "bar", with: int)
            return self.resolve(key: "bar")
        }
        
        func barwithDefault() -> String? {
            return self.resolve(key: "bar+default", defaultResult: "default value")
        }
    }
}
