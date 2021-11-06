//
//  RepositoryTests+UserDataMigration.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/11/06.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

import DataStore


class RepositoryTests_UserDataMigration: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    private var mockLocal: MockLocal!
    private var mockRemote: MockRemote!
    private var repository: DummyRepository!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockLocal = .init()
        self.mockRemote = .init()
        self.repository = .init(remote: self.mockRemote, local: self.mockLocal)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockLocal = nil
        self.mockRemote = nil
        self.repository = nil
    }
    
    private func baseMocking() {
        self.mockLocal.register(key: "removeFromAnonymousStorage") { Maybe<Void>.just() }
        self.mockLocal.register(key: "saveToUserStorage") { Maybe<Void>.just() }
    }
}

extension RepositoryTests_UserDataMigration {
    
    func testRepository_checkMigrationNeed() {
        // given
        let expect = expectation(description: "마이그레이션 필요여부 조회")
        self.mockLocal.register(key: "checkHasAnonymousStorage") { true }
        
        // when
        let checking = self.repository.checkMigrationNeed()
        let isNeed = self.waitFirstElement(expect, for: checking.asObservable())
        
        // then
        XCTAssertEqual(isNeed, true)
    }
    
    func testRepository_clearMigrationNeedData() {
        // given
        let expect = expectation(description: "미이그레이션 필요 데이터 삭제")
        self.mockLocal.register(key: "removeAnonymousStorage") { Maybe<Void>.just() }
        
        // when
        let clearing = self.repository.clearMigrationNeedData()
        let result: Void? = self.waitFirstElement(expect, for: clearing.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
}


// MARK: - test move item categories

extension RepositoryTests_UserDataMigration {
    
    private func dummyCategories(_ range: Range<Int>) -> [ItemCategory] {
        return range.map { ItemCategory(uid: "\($0)", name: "", colorCode: "") }
    }
    
    private func mockItemCategories(_ range: Range<Int>) {
        self.mockLocal.register(key: "fetchFromAnonymousStorage") {
            Maybe<[ItemCategory]>.just(self.dummyCategories(range))
        }
    }
    
    func testRepository_moveItemCategories() {
        // given
        let expect = expectation(description: "item category 마이그레이션 진행")
        expect.expectedFulfillmentCount = 3
        self.mockItemCategories(0..<50)
        self.baseMocking()
        
        // when
        let moving = self.repository.requestMoveReadItemCategories(for: "some")
        let chunks = self.waitElements(expect, for: moving.asObservable()) {
            self.mockItemCategories(50..<100)
            self.mockRemote.batchUploadMocking?(nil)
            
            self.mockItemCategories(100..<120)
            self.mockRemote.batchUploadMocking?(nil)
            
            self.mockItemCategories(120..<120)
            self.mockRemote.batchUploadMocking?(nil)
            
            self.mockRemote.batchUploadMocking?(nil)
        }
        
        // then
        let items = chunks.flatMap { $0 }
        XCTAssertEqual(items.count, 120)
    }
    
    func testRepository_whenMoveItemCategoryAndBatchuploadFail_stopMove() {
        // given
        let expect = expectation(description: "item category 마이그레이션 도중 배치업로드 실패하면 중지")
        expect.expectedFulfillmentCount = 2
        self.mockItemCategories(0..<50)
        self.baseMocking()
        var categories = [ItemCategory]()
        
        self.repository.requestMoveReadItemCategories(for: "some")
            .subscribe(onNext: {
                categories += $0
                expect.fulfill()
            }, onError: { _ in
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        
        // when
        self.mockItemCategories(100..<150)
        self.mockRemote.batchUploadMocking?(nil)
        
        self.mockItemCategories(150..<200)
        self.mockRemote.batchUploadMocking?(ApplicationErrors.invalid)
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(categories.count, 50)
    }
    
    func testRepository_whenMoveItemCategories_setupOwnerID() {
        // given
        let expect = expectation(description: "item category 마이그레이션 진행중에 ownerID 세팅")
        self.mockItemCategories(0..<50)
        self.baseMocking()
        
        // when
        let moving = self.repository.requestMoveReadItemCategories(for: "some")
        let _ = self.waitFirstElement(expect, for: moving.asObservable()) {
            self.mockItemCategories(50..<50)
            self.mockRemote.batchUploadMocking?(nil)
            
            self.mockRemote.batchUploadMocking?(nil)
        }
        
        // then
        let uploaded = self.mockRemote.didUploaded as? [ItemCategory] ?? []
        let ownerIDSet = Set(uploaded.compactMap { $0.ownerID })
        XCTAssertEqual(ownerIDSet, ["some"])
    }
}


// MARK: - move read items

extension RepositoryTests_UserDataMigration {
    
    private func dummyCollections(_ range: Range<Int>) -> [ReadCollection] {
        return range.map { ReadCollection(name: "\($0)") }
    }
    
    private func dummyLinks(_ range: Range<Int>) -> [ReadLink] {
        return range.map { ReadLink(link: "\($0)") }
    }
    
    private func mockReadCollections(_ range: Range<Int>) {
        self.mockLocal.register(key: "fetchFromAnonymousStorage") {
            Maybe<[ReadItem]>.just(self.dummyCollections(range))
        }
    }
    
    private func mockReadLink(_ range: Range<Int>) {
        self.mockLocal.register(key: "fetchFromAnonymousStorage") {
            Maybe<[ReadItem]>.just(self.dummyLinks(range))
        }
    }
    
    func testRepository_moveReadItems() {
        // given
        let expect = expectation(description: "read item 마이그레이션 진행")
        expect.expectedFulfillmentCount = 4
        self.mockReadCollections(0..<50)
        self.baseMocking()
        
        // when
        let moving = self.repository.requestMoveReadItems(for: "some")
        let chunks = self.waitElements(expect, for: moving.asObservable()) {
            self.mockReadCollections(50..<100)
            self.mockRemote.batchUploadMocking?(nil)
            
            self.mockReadLink(0..<50)
            self.mockRemote.batchUploadMocking?(nil)
            
            self.mockReadLink(50..<100)
            self.mockRemote.batchUploadMocking?(nil)
            
            self.mockReadLink(100..<100)
            self.mockRemote.batchUploadMocking?(nil)
            
            self.mockRemote.batchUploadMocking?(nil)
        }
        
        // then
        let items = chunks.flatMap { $0 }
        XCTAssertEqual(items.count, 200)
        
        let didUploadItem = self.mockRemote.didUploaded as? [ReadItem] ?? []
        let ownerIDSet = Set(didUploadItem.compactMap { $0.ownerID })
        XCTAssertEqual(ownerIDSet, ["some"])
    }
    
    private func mockMemos(_ range: Range<Int>) {
        let memos = range.map { ReadLinkMemo(itemID: "\($0)") }
        self.mockLocal.register(key: "fetchFromAnonymousStorage") {
            Maybe<[ReadLinkMemo]>.just(memos)
        }
    }
    
    func testRepository_moveLiveMemos() {
        // given
        let expect = expectation(description: "read item 마이그레이션 진행")
        expect.expectedFulfillmentCount = 2
        self.mockMemos(0..<50)
        self.baseMocking()
        
        // when
        let moving = self.repository.requestMoveReadLinkMemos(for: "some")
        let chunks = self.waitElements(expect, for: moving.asObservable()) {
            self.mockMemos(50..<100)
            self.mockRemote.batchUploadMocking?(nil)
            
            self.mockMemos(100..<100)
            self.mockRemote.batchUploadMocking?(nil)
            
            self.mockRemote.batchUploadMocking?(nil)
        }
        
        // then
        let memos = chunks.flatMap { $0 }
        XCTAssertEqual(memos.count, 100)
    }
}


extension RepositoryTests_UserDataMigration {
    
    class DummyRepository: UserDataMigrateRepository, UserDataMigrationRepositoryDefImpleDependency {
        
        let disposeBag: DisposeBag = .init()
        let migrateRemote: BatchUploadRemote
        let migrateLocal: DataModelStorageSwitchable & UserDataMigratableLocalStorage
        
        init(remote: BatchUploadRemote,
             local: DataModelStorageSwitchable & UserDataMigratableLocalStorage) {
            self.migrateRemote = remote
            self.migrateLocal = local
        }
    }
}
