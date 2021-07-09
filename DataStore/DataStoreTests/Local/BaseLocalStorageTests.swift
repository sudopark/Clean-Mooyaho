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
    var stubEnvironmentStorage: StubEnvironmentStorage!
    var stubEncrytedStorage: StubEncryptedStorage!
    var local: LocalStorageImple!
    
    private var testDBPath: String {
        return try! FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("test.db")
            .path
            
    }
    
    override func setUpWithError() throws {
        
        self.timeout = 1.0
        
        self.disposeBag = .init()
        
        self.stubEncrytedStorage = StubEncryptedStorage()
        self.stubEnvironmentStorage = .init()
        let dataModelStorage = DataModelStorageImple(dbPath: self.testDBPath, verstion: 0)
        self.local = LocalStorageImple(encryptedStorage: stubEncrytedStorage,
                                       environmentStorage: UserDefaults.standard,
                                       dataModelStorage: dataModelStorage)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.stubEncrytedStorage = nil
        self.stubEnvironmentStorage = nil
        self.local = nil
        try? FileManager.default.removeItem(atPath: self.testDBPath)
    }
}


extension BaseLocalStorageTests {
    
    class StubEncryptedStorage: EncryptedStorage, Stubbable {
        
        func save<V>(_ key: String, value: V) -> Result<Void, Error> {
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


extension BaseLocalStorageTests {
    
    class StubEnvironmentStorage: EnvironmentStorage, Stubbable {
        
        func savePendingNewPlaceForm(_ form: NewPlaceForm) -> Maybe<Void> {
            return self.resolve(key: "savePendingNewPlaceForm") ?? .empty()
        }
        
        func fetchPendingNewPlaceForm(_ memberID: String) -> Maybe<PendingRegisterNewPlaceForm?> {
            return self.resolve(key: "fetchPendingNewPlaceForm") ?? .empty()
        }
        
        func removePendingNewPlaceForm(_ memberID: String) -> Maybe<Void> {
            return self.resolve(key: "removePendingNewPlaceForm") ?? .empty()
        }
    }
}
