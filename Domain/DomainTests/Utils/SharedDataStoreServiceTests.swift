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
        let valueBeforeSave = self.store.get(Int.self, key: "k1")
        
        // when
        self.store.update(Int.self, key:"k1", value: 1)
        let valueAfterSave = self.store.get(Int.self, key:"k1")
        let value2 = self.store.get(Int.self, key:"k2")
        
        // then
        XCTAssertEqual(valueBeforeSave, nil)
        XCTAssertEqual(valueAfterSave, 1)
        XCTAssertEqual(value2, nil)
    }
    
    func testStore_delete() {
        // given
        self.store.update(Int.self, key:"k1", value: 1)
        
        // when
        self.store.delete("k1")
        
        // then
        let stored = self.store.get(Int.self, key:"k1")
        XCTAssertNil(stored)
    }
    
    func testStore_observeUpdates() {
        // given
        let expect = expectation(description: "발류 업데이트 관찰")
        expect.expectedFulfillmentCount = 10
        
        // when
        let observingValue = self.store.observe(Int.self, key:"k1")
        let values = self.waitElements(expect, for: observingValue) {
            (0..<10).forEach{
                self.store.update(Int.self, key:"k1", value: $0)
            }
        }
        
        // then
        XCTAssertEqual(values, Array(0..<10))
    }
    
    func testStore_whenAlreadyDataStoredAndObserve_startWithExistingValue() {
        // given
        let expect = expectation(description: "발류 업데이트 관찰시 이미 저장되어있는 값 있으면 초기이벤트로 시작")
        expect.expectedFulfillmentCount = 11
        self.store.update(Int.self, key:"k1", value: -1)
        
        // when
        let observingValue = self.store.observe(Int.self, key:"k1")
        let values = self.waitElements(expect, for: observingValue) {
            (0..<10).forEach{
                self.store.update(Int.self, key:"k1", value: $0)
            }
        }
        
        // then
        XCTAssertEqual(values, Array(-1..<10))
    }
}


extension SharedDataStoreServiceTests {
    
    private var ids: [Int] { (0..<3).map { $0 }  }
    
    // 모든 데이터가 메모리에 있는경우
    func testStore_observeValueWithsetup_allDataInMemory() {
        // given
        let expect = expectation(description: "구독하려는 데이터가 모두 메모리에 올라와있는 경우")
        let valueMap = self.ids.reduce(into: [String: Int]()) { $0["\($1)"] = $1 }
        self.store.update([String: Int].self, key: "some", value: valueMap)
        
        // when
        let observingValues: Observable<[Int]> = self.store
            .observeValuesInMappWithSetup(ids: self.ids.map{ "\($0)" }, sharedKey: "some", disposeBag: self.disposeBag,
                                    idSelector: { "\($0)" },
                                    localFetchinig: { _ in .empty() },
                                    remoteLoading: { _ in .empty() } )
        let values = self.waitFirstElement(expect, for: observingValues)
        
        // then
        XCTAssertEqual(values, [0, 1, 2])
    }
    
    // 메모리에 없는것들은 캐시에서 불러옴
    func testStore_observeValueWithsetup_prepareDataFromLocal() {
        // given
        let expect = expectation(description: "구독하려는 데이터 중 일부가 로컬에 있는 경우")
        expect.expectedFulfillmentCount = 2
        let valueMap = ["0": 0]
        self.store.update([String: Int].self, key: "some", value: valueMap)
        
        // when
        let observingValues: Observable<[Int]> = self.store
            .observeValuesInMappWithSetup(ids: self.ids.map{ "\($0)" }, sharedKey: "some", disposeBag: self.disposeBag,
                                    idSelector: { "\($0)" },
                                    localFetchinig: { _ in .just([1]) },
                                    remoteLoading: { _ in .just([]) } )
        let valueStream = self.waitElements(expect, for: observingValues)
        
        // then
        XCTAssertEqual(valueStream, [[0], [0, 1]])
    }
    
    // 캐시에도 없는것은 리모트에서 불러와서 준비
    func testStore_observeValueWithsetup_prepareDataFromLocalAndRemote() {
        // given
        let expect = expectation(description: "구독하려는 데이터 중 일부가 로컬과 리모트에 있는 경우")
        expect.expectedFulfillmentCount = 2
        let valueMap = ["0": 0]
        self.store.update([String: Int].self, key: "some", value: valueMap)
        
        // when
        let observingValues: Observable<[Int]> = self.store
            .observeValuesInMappWithSetup(ids: self.ids.map{ "\($0)" }, sharedKey: "some", disposeBag: self.disposeBag,
                                    idSelector: { "\($0)" },
                                    localFetchinig: { _ in .just([1]) },
                                    remoteLoading: { _ in .just([2]) } )
        let valueStream = self.waitElements(expect, for: observingValues)
        
        // then
        XCTAssertEqual(valueStream, [[0], [0, 1, 2]])
    }
}
