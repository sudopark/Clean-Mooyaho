//
//  SharedDataStoreServiceTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import RxRelay

import UnitTestHelpKit

@testable import Domain


class SharedDataStoreServiceTests: BaseTestCase, WaitObservableEvents {
    
    enum TestKeys: String {
        case key1
        case key2
    }
    
    var disposeBag: DisposeBag!
    var store: SharedDataStoreServiceImple!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.store = .init()
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.store = nil
        super.tearDown()
    }
}


extension SharedDataStoreServiceTests {
    
    func testStore_saveAndFetchValue() {
        // given
        let valueBeforeSave: Int? = self.store.fetch("k1")
        
        // when
        self.store.save("k1", value: 1)
        let valueAfterSave: Int? = self.store.fetch("k1")
        let value2: Int? = self.store.fetch("k2")
        
        // then
        XCTAssertEqual(valueBeforeSave, nil)
        XCTAssertEqual(valueAfterSave, 1)
        XCTAssertEqual(value2, nil)
    }
    
    func testStore_delete() {
        // given
        self.store.save("k1", value: 1)
        
        // when
        self.store.delete("k1")
        
        // then
        let stored: Int? = self.store.fetch("k1")
        XCTAssertNil(stored)
    }
    
    func testStore_observeUpdates() {
        // given
        let expect = expectation(description: "발류 업데이트 관찰")
        expect.expectedFulfillmentCount = 10
        
        // when
        let observingValue: Observable<Int> = self.store.observe("k1")
        let values = self.waitElements(expect, for: observingValue) {
            (0..<10).forEach{
                self.store.save("k1", value: $0)
            }
        }
        
        // then
        XCTAssertEqual(values, Array(0..<10))
    }
    
    func testStore_whenAlreadyDataStoredAndObserve_startWithExistingValue() {
        // given
        let expect = expectation(description: "발류 업데이트 관찰시 이미 저장되어있는 값 있으면 초기이벤트로 시작")
        expect.expectedFulfillmentCount = 11
        self.store.save("k1", value: -1)
        
        // when
        let observingValue: Observable<Int> = self.store.observe("k1")
        let values = self.waitElements(expect, for: observingValue) {
            (0..<10).forEach{
                self.store.save("k1", value: $0)
            }
        }
        
        // then
        XCTAssertEqual(values, Array(-1..<10))
    }
}
