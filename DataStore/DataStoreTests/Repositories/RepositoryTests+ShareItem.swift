//
//  RepositoryTests+ShareItem.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

import DataStore


class RepositoryTests_ShareItem: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockLocal: MockLocal!
    var mockRemote: MockRemote!
    var repository: Repository!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockRemote = .init()
        self.mockLocal = .init()
        self.repository = .init(shareItemRemote: self.mockRemote, shareItemLocal: self.mockLocal)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockLocal = nil
        self.mockRemote = nil
        self.repository = nil
    }
}


extension RepositoryTests_ShareItem {
    
    func testRepository_shareItem() {
        // given
        let expect = expectation(description: "item share")
        expect.expectedFulfillmentCount = 2
        self.mockRemote.register(key: "requestShare") {
            Maybe<SharedReadCollection>.just(SharedReadCollection(shareID: "some", collection: .init(name: "name")))
        }
        self.mockLocal.register(key: "fetchMySharingItemIDs") { Maybe<[String]>.just([]) }
        self.mockLocal.called(key: "updateMySharingItemIDs") { _ in
            expect.fulfill()
        }
        
        // when
        let sharing = self.repository.requestShareCollection("some")
        let result = self.waitFirstElement(expect, for: sharing.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_stopShareItem() {
        // given
        let expect = expectation(description: "stop item share")
        expect.expectedFulfillmentCount = 2
        self.mockRemote.register(key: "requestStopShare") { Maybe<Void>.just() }
        self.mockLocal.register(key: "fetchMySharingItemIDs") { Maybe<[String]>.just([]) }
        self.mockLocal.called(key: "updateMySharingItemIDs") { _ in
            expect.fulfill()
        }
        
        // when
        let stopSharing = self.repository.requestStopShare(readCollection: "some")
        let result: Void? = self.waitFirstElement(expect, for: stopSharing.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_loadMySharingItemIDs() {
        // given
        let expect = expectation(description: "내가 공유중인 콜렉션 아이디 목록 로드")
        expect.expectedFulfillmentCount = 3
        self.mockLocal.register(key: "fetchMySharingItemIDs") { Maybe<[String]>.just([]) }
        self.mockRemote.register(key: "requestLoadMySharingCollectionIDs") { Maybe<[String]>.just([]) }
        self.mockLocal.called(key: "updateMySharingItemIDs") { _ in
            expect.fulfill()
        }
        
        // when
        let loading = self.repository.requestLoadMySharingCollectionIDs()
        let ids = self.waitElements(expect, for: loading.asObservable())
        
        // then
        XCTAssertEqual(ids.count, 2)
    }
    
    func testRepository_loadLatestSharedCollection_withCache() {
        // given
        let expect = expectation(description: "최근 공유된 콜렉션 목록 로드")
        expect.expectedFulfillmentCount = 2
        self.mockLocal.register(key: "fetchLatestSharedCollections")
            { Maybe<[SharedReadCollection]>.just([SharedReadCollection(shareID: "some", collection: .init(name: "name"))]) }
        self.mockRemote.register(key: "requestLoadLatestSharedCollections")
            { Maybe<[SharedReadCollection]>.just([SharedReadCollection(shareID: "some", collection: .init(name: "name"))]) }
        
        // when
        let loading = self.repository.requestLoadLatestsSharedCollections()
        let collectionLists = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(collectionLists.count, 2)
        XCTAssertEqual(collectionLists.first?.count, 1)
        XCTAssertEqual(collectionLists.last?.count, 1)
    }
    
    func testReposiotry_whenLoadLatestSharedCollectionAndFetchCacheFail_ignore() {
        // given
        let expect = expectation(description: "최근 공유된 콜렉션 목록 로드 중 캐시로드 실패는 무시")
        expect.expectedFulfillmentCount = 2
        self.mockLocal.register(key: "fetchLatestSharedCollections") { Maybe<[SharedReadCollection]>.error(ApplicationErrors.invalid) }
        self.mockRemote.register(key: "requestLoadLatestSharedCollections") { Maybe<[SharedReadCollection]>.just([SharedReadCollection(shareID: "some", collection: .init(name: "name"))]) }
        
        // when
        let loading = self.repository.requestLoadLatestsSharedCollections()
        let collectionLists = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(collectionLists.count, 2)
        XCTAssertEqual(collectionLists.first?.count, 0)
        XCTAssertEqual(collectionLists.last?.count, 1)
    }
    
    func testReposiroey_whenAfterLoadLatestSharedItem_updateLocal() {
        // given
        let expect = expectation(description: "최근 공유받은 목록 로드 이후에 캐시 업데이트")
        self.mockLocal.called(key: "replaceLastSharedCollections") { _ in
            expect.fulfill()
        }
        self.mockLocal.register(key: "fetchLatestSharedCollections") { Maybe<[SharedReadCollection]>.error(ApplicationErrors.invalid) }
        self.mockRemote.register(key: "requestLoadLatestSharedCollections") { Maybe<[SharedReadCollection]>.just([SharedReadCollection(shareID: "some", collection: .init(name: "name"))]) }
        
        // when
        self.repository.requestLoadLatestsSharedCollections()
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testRepository_loadFailSharedCollection() {
        // given
        let expect = expectation(description: "최근 공유된 콜렉션 목록 로드 실패")
        self.mockLocal.register(key: "fetchLatestSharedCollections") { Maybe<[SharedReadCollection]>.just([]) }
        self.mockRemote.register(key: "requestLoadLatestSharedCollections") { Maybe<[SharedReadCollection]>.error(ApplicationErrors.invalid) }
        
        // when
        let loading = self.repository.requestLoadLatestsSharedCollections()
        let error = self.waitError(expect, for: loading)
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testRepository_loadSharedCollection() {
        // given
        let expect = expectation(description: "공유받은 콜렉션 로드")
        self.mockRemote.register(key: "requestLoadSharedCollection") {
            Maybe<SharedReadCollection>.just(SharedReadCollection(shareID: "some", collection: .init(name: "name")))
        }
        
        // when
        let loading = self.repository.requestLoadSharedCollection(by: "some")
        let collection = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertNotNil(collection)
    }
    
    func testReposiroey_whenAfterLoadSharedItem_updateLocal() {
        // given
        let expect = expectation(description: "공유받은 콜렉션 로드 이후에 캐시 업데이트")
        self.mockLocal.called(key: "saveSharedCollection") { _ in
            expect.fulfill()
        }
        self.mockRemote.register(key: "requestLoadSharedCollection") {
            Maybe<SharedReadCollection>.just(SharedReadCollection(shareID: "some", collection: .init(name: "name")))
        }
        
        // when
        self.repository.requestLoadSharedCollection(by: "some")
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


extension RepositoryTests_ShareItem {
    
    class Repository: ShareItemRepository, ShareItemReposiotryDefImpleDependency {
        
        let disposeBag: DisposeBag = .init()
        let shareItemRemote: ShareItemRemote
        let shareItemLocal: ShareItemLocalStorage
        
        init(shareItemRemote: ShareItemRemote,
             shareItemLocal: ShareItemLocalStorage) {
            self.shareItemRemote = shareItemRemote
            self.shareItemLocal = shareItemLocal
        }
    }
}
