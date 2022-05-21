//
//  BaseLocalStorageTests.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/06/26.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

@testable import DataStore


class BaseLocalStorageTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockEncrytedStorage: MockEncryptedStorage!
    var testEnvironmentStorage: EnvironmentStorage!
    var local: LocalStorageImple!
    
    func testDBPath(_ name: String) -> String {
        return try! FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("\(name).db")
            .path
            
    }
    
    override func setUpWithError() throws {
        
        self.timeout = 1.0
        
        self.disposeBag = .init()
        
        self.mockEncrytedStorage = MockEncryptedStorage()
        
        environmentStorageKeyPrefix = "test"
        self.testEnvironmentStorage = UserDefaults.standard

        let path = self.testDBPath("test1")
        let gateway = DataModelStorageGatewayImple(anonymousStoragePath: path,
                                                   makeAnonymousStorage: {
            DataModelStorageImple(dbPath: self.testDBPath("test1"), version: 0, closeWhenDeinit: false)
            
        }, makeUserStorage: { _ in
            DataModelStorageImple(dbPath: self.testDBPath("test2"), version: 0, closeWhenDeinit: false)
        })
        gateway.openAnonymousStorage().subscribe().disposed(by: self.disposeBag)
        gateway.openUserStorage("some").subscribe().disposed(by: self.disposeBag)
        
        self.local = LocalStorageImple(encryptedStorage: mockEncrytedStorage,
                                       environmentStorage: UserDefaults.standard,
                                       dataModelGateway: gateway)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockEncrytedStorage = nil
        self.testEnvironmentStorage.clearAll(scope: .perUser)
        self.testEnvironmentStorage.clearAll(scope: .perDevice)
        self.local = nil
        try? FileManager.default.removeItem(atPath: self.testDBPath("test1"))
        try? FileManager.default.removeItem(atPath: self.testDBPath("test2"))
    }
}


extension BaseLocalStorageTests {
    
    class MockEncryptedStorage: EncryptedStorage, Mocking {
        
        func setupSharedGroup(_ identifier: String) { }
        
        var didSavedValue: Any?
        func save<V>(_ key: String, value: V) -> Result<Void, Error> {
            self.didSavedValue = value
            self.register(key: "fetch") { Result<V?, Error>.success(value) }
            return .success(())
        }
        
        func fetch<V>(_ key: String) -> Result<V?, Error> {
            return self.resolve(key: "fetch") ?? .success(nil)
        }

        func delete(_ key: String) -> Bool {
            return true
        }
    }
}
