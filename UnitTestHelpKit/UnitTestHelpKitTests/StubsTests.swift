//
//  StubsTests.swift
//  UnitTestHelpKitTests
//
//  Created by ParkHyunsoo on 2021/04/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest
@testable import UnitTestHelpKit


class StubsTests: XCTestCase {
    
    
    func testStub_registerAndResolve() {
        // given
        let stub = Stub()
        
        // when
        stub.register(key: "bar") { "some" }
        
        // then
        let result = stub.bar(0)
        XCTAssertEqual(result, "some")
    }
    
    func testStub_resolveNotRegisteredValue() {
        // given
        let stub = Stub()
        
        // when
        // then
        let result = stub.bar(0)
        XCTAssertEqual(result, nil)
    }
    
    func testStub_whenResolveNotRegisterValueWithDefaultValue_returnDefaultValue() {
        // given
        let stub = Stub()
        
        // when
        // then
        let result = stub.barwithDefault()
        XCTAssertEqual(result, "default value")
    }
    
    func testStub_called() {
        // given
        let stub = Stub()
        var isCalled = false
        
        stub.called(key: "bar") { args in
            if let int = args as? Int, int == 100 {
                isCalled = true
            }
        }
        
        // when
        _ = stub.bar(100)
        
        // then
        XCTAssertEqual(isCalled, true)
    }
}


extension StubsTests {
    
    class Stub: Stubbable {
        
        func bar(_ int: Int) -> String? {
            self.verify(key: "bar", with: int)
            return self.resolve(key: "bar")
        }
        
        func barwithDefault() -> String? {
            return self.resolve(key: "bar+default", defaultResult: "default value")
        }
    }
}
