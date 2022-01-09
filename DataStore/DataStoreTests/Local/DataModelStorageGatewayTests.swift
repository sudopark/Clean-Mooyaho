//
//  DataModelStorageGateWayTests.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/11/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import UnitTestHelpKit

@testable import DataStore
import XCTest


class DataModelStorageGatewayTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyAnonymousStorage: DataModelStorageImple!
    var spyUserStorage: DataModelStorageImple!
    
    private func testDBPath(_ name: String) -> String {
        return try! FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("\(name).db")
            .path
            
    }
    
    override func setUpWithError() throws {
        self.timeout = 1
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyUserStorage = nil
        self.spyAnonymousStorage = nil
        try? FileManager.default.removeItem(atPath: self.testDBPath("gateway-test"))
        try? FileManager.default.removeItem(atPath: self.testDBPath("gateway-test-some"))
    }
    
    private func makeAnonymousStorage() -> DataModelStorage {
        let path = self.testDBPath("gateway-test")
        let storage = DataModelStorageImple(dbPath: path)
        self.spyAnonymousStorage = storage
        return storage
    }
    
    private func makeUserStroage(_ userID: String) -> DataModelStorage {
        let path = self.testDBPath("gateway-test-\(userID)")
        let storage = DataModelStorageImple(dbPath: path)
        self.spyUserStorage = storage
        return storage
    }
    
    private func makeGateway() -> DataModelStorageGateway {
        
        let path = self.testDBPath("gateway-test")
        return DataModelStorageGatewayImple(anonymousStoragePath: path,
                                            makeAnonymousStorage: self.makeAnonymousStorage,
                                            makeUserStorage: self.makeUserStroage(_:))
    }
}


extension DataModelStorageGatewayTests {
    
    // not signed in case
    func testGateway_openAnonymousStorage() {
        // given
        let expect = expectation(description: "익명 저장소 오픈")
        let gateway = self.makeGateway()
        
        // when
        let opening = gateway.openAnonymousStorage()
        let result: Void? = self.waitFirstElement(expect, for: opening.asObservable())
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(self.spyAnonymousStorage?.isOpen, true)
        XCTAssertEqual(self.spyUserStorage?.isOpen, nil)
    }
    
    // already signed in case
    func testGateway_openUserStorage() {
        // given
        let expect = expectation(description: "로그인 유저 저장소 오픈")
        let gateway = self.makeGateway()
        
        // when
        let opening = gateway.openUserStorage("some")
        let result: Void? = self.waitFirstElement(expect, for: opening.asObservable())
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(self.spyAnonymousStorage?.isOpen, nil)
        XCTAssertEqual(self.spyUserStorage?.isOpen, true)
    }
    
    // sign in case
    func testGateway_switchToUserStorage() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 저장소 변환")
        let gateway = self.makeGateway()
        
        // when
        let opening = gateway.openAnonymousStorage()
        let openThenSwitch = opening
            .flatMap { gateway.switToUserStorage("some") }
        let result: Void? = self.waitFirstElement(expect, for: openThenSwitch.asObservable())
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(self.spyAnonymousStorage?.isOpen, false)
        XCTAssertEqual(self.spyUserStorage?.isOpen, true)
    }
    
    // sign out case
    func testGateway_switchToAnonymousStorage() {
        // given
        let expect = expectation(description: "로그인 상태에서 저장소 변환")
        let gateway = self.makeGateway()
        
        // when
        let opening = gateway.openUserStorage("some")
        let openThenSwitch = opening
            .flatMap { gateway.switchToAnonymousStorage() }
        let result: Void? = self.waitFirstElement(expect, for: openThenSwitch.asObservable())
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(self.spyAnonymousStorage?.isOpen, true)
        XCTAssertEqual(self.spyUserStorage?.isOpen, false)
    }
}
