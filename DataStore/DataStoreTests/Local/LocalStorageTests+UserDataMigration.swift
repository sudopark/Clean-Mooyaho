//
//  LocalStorageTests+UserDataMigration.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/11/06.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

@testable import DataStore


class LocalStorageTests_UserDataMigration: BaseLocalStorageTests {
    
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
        
        self.local = LocalStorageImple(encryptedStorage: mockEncrytedStorage,
                                       environmentStorage: UserDefaults.standard,
                                       dataModelGateway: gateway)
        
    }
}


extension LocalStorageTests_UserDataMigration {
    
    func testStorage_loadItemCategories_untilIsNotEmpty() {
        // given
        let expect = expectation(description: "저장된 카테고리 있을때까지 계속로드하며 삭제")
        let categories = (0..<101).map { ItemCategory(name: "\($0)", colorCode: "") }
        let save = self.local.switchToAnonymousStorage()
            .flatMap { self.local.saveToUserStorage(ItemCategory.self, categories) }
            .flatMap { self.local.switchToUserStorage("some") }
        
        // when
        let loadFirst50 = self.local.fetchFromAnonymousStorage(ItemCategory.self, size: 50)
        let remove = self.local.removeFromAnonymousStorage(ItemCategory.self, in: categories[0..<50].map { $0.uid })
        let loadAgain = self.local.fetchFromAnonymousStorage(ItemCategory.self, size: 50)
        let removeAgain = self.local.removeFromAnonymousStorage(ItemCategory.self, in: categories[50..<100].map { $0.uid })
        let loadLast = self.local.fetchFromAnonymousStorage(ItemCategory.self, size: 50)
        let loadUntilLastOne = save.flatMap { loadFirst50 }.flatMap { _ in remove }
            .flatMap { loadAgain }.flatMap { _ in removeAgain }
            .flatMap { loadLast }
        let lastRemain = self.waitFirstElement(expect, for: loadUntilLastOne.asObservable())
        
        // then
        XCTAssertEqual(lastRemain?.count, 1)
        XCTAssertEqual(lastRemain?.first?.uid, categories.last?.uid)
    }
    
    func testStorage_loadReadItems_untilIsNotEmpty() {
        // given
        let expect = expectation(description: "read item 없을때까지 로드하고 삭제")
        let collections = (0..<100).map { ReadCollection(name: "\($0)") }
        let links = (0..<101).map { ReadLink(link: "\($0)") }
        let items: [ReadItem] = (collections + links)
        let save = self.local.switchToAnonymousStorage()
            .flatMap { self.local.saveToUserStorage(ReadItem.self, items) }
            .flatMap { self.local.switchToUserStorage("some") }
        
        // when
        let loadCollection0 = self.local.fetchFromAnonymousStorage(ReadItem.self, size: 50)
        let removeCollection0 = self.local.removeFromAnonymousStorage(ReadItem.self,
                                                                      in: collections[0..<50].map { $0.uid })
        let loadCollection1 = self.local.fetchFromAnonymousStorage(ReadItem.self, size: 50)
        let removeCollection1 = self.local.removeFromAnonymousStorage(ReadItem.self,
                                                                      in: collections[50..<100].map { $0.uid })
        let loadLinks0 = self.local.fetchFromAnonymousStorage(ReadItem.self, size: 50)
        let removeLink0 = self.local.removeFromAnonymousStorage(ReadItem.self, in: links[0..<50].map { $0.uid })
        let loadLink1 = self.local.fetchFromAnonymousStorage(ReadItem.self, size: 50)
        let removeLink1 = self.local.removeFromAnonymousStorage(ReadItem.self, in: links[50..<100].map { $0.uid })
        let loadLast = self.local.fetchFromAnonymousStorage(ReadItem.self, size: 50)
        let loadUntilLastOne = save
            .flatMap { loadCollection0 }.flatMap { _ in removeCollection0 }
            .flatMap { loadCollection1 }.flatMap { _ in removeCollection1 }
            .flatMap { loadLinks0 }.flatMap { _ in removeLink0 }
            .flatMap { loadLink1 }.flatMap { _ in removeLink1 }
            .flatMap { loadLast }
        let remains = self.waitFirstElement(expect, for: loadUntilLastOne.asObservable())
        
        // then
        XCTAssertEqual(remains?.count, 1)
        XCTAssertEqual(remains?.first?.uid, links.last?.uid)
    }
    
    func testStorage_loadLinkMemo_untilIsNotEmpty() {
        // given
        let expect = expectation(description: "read memo 없을때까지 로드")
        let memos = (0..<101).map { ReadLinkMemo(itemID: "\($0)") }
        let save = self.local.switchToAnonymousStorage()
            .flatMap { self.local.saveToUserStorage(ReadLinkMemo.self, memos) }
            .flatMap { self.local.switchToUserStorage("some") }
        
        // when
        let load0 = self.local.fetchFromAnonymousStorage(ReadLinkMemo.self, size: 50)
        let remove0 = self.local.removeFromAnonymousStorage(ReadLinkMemo.self, in: memos[0..<50].map { $0.linkItemID })
        let load1 = self.local.fetchFromAnonymousStorage(ReadLinkMemo.self, size: 50)
        let remove1 = self.local.removeFromAnonymousStorage(ReadLinkMemo.self, in: memos[50..<100].map { $0.linkItemID })
        let loadLast = self.local.fetchFromAnonymousStorage(ReadLinkMemo.self, size: 50)
        let loadUntilLastOne = save
            .flatMap { load0 }.flatMap { _ in remove0 }
            .flatMap { load1 }.flatMap { _ in remove1 }
            .flatMap { loadLast }
        let remains = self.waitFirstElement(expect, for: loadUntilLastOne.asObservable())
        
        // then
        XCTAssertEqual(remains?.count, 1)
        XCTAssertEqual(remains?.first?.linkItemID, memos.last?.linkItemID)
    }
}
