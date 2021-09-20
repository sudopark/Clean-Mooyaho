//
//  RepositoryTests+ReadItem.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/09/16.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

import DataStore


class RepositoryTests_ReadItem: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockRemote: MockRemote!
    var mockLocal: MockLocal!
    var dummyRepository: DummyRepository!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockRemote = .init()
        self.mockLocal = .init()
        self.dummyRepository = .init(remote: self.mockRemote, local: self.mockLocal)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockRemote = nil
        self.mockLocal = nil
        self.dummyRepository = nil
    }
}


// MAKR: - test sign out case

extension RepositoryTests_ReadItem {
    
    // load my items
    func testRepository_fetchdMyItems() {
        // given
        let expect = expectation(description: "내 아이템 패칭")
        
        self.mockLocal.register(key: "fetchMyItems") { Maybe<[ReadItem]>.just([]) }
        
        // when
        let fetching = self.dummyRepository.fetchMyItems()
        let items = self.waitElements(expect, for: fetching.asObservable())
        
        // then
        XCTAssertEqual(items.count, 1)
    }
    
    func testRepository_fetchdMyItemsFail() {
        // given
        let expect = expectation(description: "내 아이템 패칭 실패")
        
        self.mockLocal.register(key: "fetchMyItems") { Maybe<[ReadItem]>.error(LocalErrors.invalidData(nil)) }
        
        // when
        let fetching = self.dummyRepository.fetchMyItems()
        let error = self.waitError(expect, for: fetching.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    // load collectionItems
    func testRepository_fetchCollectionItems() {
        // given
        let expect = expectation(description: "상태에서 특정 콜렉션 아이템 패칭")
        
        self.mockLocal.register(key: "fetchCollectionItems") { Maybe<[ReadItem]>.just([]) }
        
        // when
        let fetching = self.dummyRepository.fetchCollectionItems(collectionID: "some")
        let items = self.waitElements(expect, for: fetching.asObservable())
        
        // then
        XCTAssertEqual(items.count, 1)
    }
    
    func testRepository_fetchCollectionItemsFail() {
        // given
        let expect = expectation(description: "특정 콜렉션 아이템 패칭 실패")
        
        self.mockLocal.register(key: "fetchCollectionItems") { Maybe<[ReadItem]>.error(LocalErrors.invalidData(nil)) }
        
        // when
        let fetching = self.dummyRepository.fetchCollectionItems(collectionID: "some")
        let error = self.waitError(expect, for: fetching.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    // udpate collection
    func testRepository_updateCollection() {
        // given
        let expect = expectation(description: "특정 콜렉션 업데이트")
        
        self.mockLocal.register(key: "updateReadItems") { Maybe<Void>.just() }
        
        // when
        let updating = self.dummyRepository.updateCollection(.init(name: "some"))
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_updateCollectionFail() {
        // given
        let expect = expectation(description: "특정 콜렉션 업데이트 실패")
        
        self.mockLocal.register(key: "updateReadItems") { Maybe<Void>.error(LocalErrors.invalidData(nil)) }
        
        // when
        let updating = self.dummyRepository.updateCollection(.init(name: "some"))
        let error = self.waitError(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    // save link item
    func testRepository_updateReadLink() {
        // given
        let expect = expectation(description: "읽기링크 저장")
        
        self.mockLocal.register(key: "updateReadItems") { Maybe<Void>.just() }
        
        // when
        let saving = self.dummyRepository.updateLink(.init(link: "some"))
        let result: Void? = self.waitFirstElement(expect, for: saving.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_updateReadLinkFail() {
        // given
        let expect = expectation(description: "읽기링크 저장 실패")
        
        self.mockLocal.register(key: "updateReadItems") { Maybe<Void>.error(LocalErrors.invalidData(nil)) }
        
        // when
        let saving = self.dummyRepository.updateLink(.init(link: "some"))
        let error = self.waitError(expect, for: saving.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
}


// MARK: - test sign in case: load my items

extension RepositoryTests_ReadItem {
    
    func testRepository_whenSignInAndLoadMyItems_localFirstAndRemote() {
        // given
        let expect = expectation(description: "로그인 상태에서 내 아이템 로드시 로컬 패칭 이후 리모트 로드")
        expect.expectedFulfillmentCount = 2
        
        self.mockLocal.register(key: "fetchMyItems") { Maybe<[ReadItem]>.just([]) }
        self.mockRemote.register(key: "requestLoadMyItems") { Maybe<[ReadItem]>.just([]) }
        
        // when
        let loading = self.dummyRepository.requestLoadMyItems(for: "some")
        let lists = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(lists.count, 2)
    }
    
    func testRepository_whenSignInAndLoadMyItems_localFirstAndRemoteWithIgnoreLocalError() {
        // given
        let expect = expectation(description: "로그인 상태에서 내 아이템 로드시 로컬 패칭 에러는 무시 이후 리모트 로드")
        expect.expectedFulfillmentCount = 1
        
        self.mockLocal.register(key: "fetchMyItems") { Maybe<[ReadItem]>.error(LocalErrors.deserializeFail(nil)) }
        self.mockRemote.register(key: "requestLoadMyItems") { Maybe<[ReadItem]>.just([]) }
        
        // when
        let loading = self.dummyRepository.requestLoadMyItems(for: "some")
        let lists = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(lists.count, 1)
    }
    
    func testRepository_whenSignInAndLoadMyItemsFail_byRemoteFail() {
        // given
        let expect = expectation(description: "로그인 상태에서 내 아이템 로드시 리모트 실패면 에러방출")
        
        self.mockLocal.register(key: "fetchMyItems") { Maybe<[ReadItem]>.just([]) }
        self.mockRemote.register(key: "requestLoadMyItems") { Maybe<[ReadItem]>.error(LocalErrors.deserializeFail(nil)) }
        
        // when
        let loading = self.dummyRepository.requestLoadMyItems(for: "some")
        let error = self.waitError(expect, for: loading)
        
        // then
        XCTAssertNotNil(error)
    }
}

// MARK: - test sign in case: load collection items

extension RepositoryTests_ReadItem {
    
    func testRepository_whenSignInAndLoadCollectionItems_localFirstAndRemote() {
        // given
        let expect = expectation(description: "로그인 상태에서 collection 아이템 로드시 로컬 패칭 이후 리모트 로드")
        expect.expectedFulfillmentCount = 2
        
        self.mockLocal.register(key: "fetchCollectionItems") { Maybe<[ReadItem]>.just([]) }
        self.mockRemote.register(key: "requestLoadCollectionItems") { Maybe<[ReadItem]>.just([]) }
        
        // when
        let loading = self.dummyRepository.requestLoadCollectionItems(collectionID: "some")
        let lists = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(lists.count, 2)
    }
    
    func testRepository_whenSignInAndLoadCollectionItems_localFirstAndRemoteWithIgnoreLocalError() {
        // given
        let expect = expectation(description: "로그인 상태에서 내 아이템 로드시 로컬 패칭 에러는 무시 이후 리모트 로드")
        expect.expectedFulfillmentCount = 1
        
        self.mockLocal.register(key: "fetchCollectionItems") { Maybe<[ReadItem]>.error(LocalErrors.deserializeFail(nil)) }
        self.mockRemote.register(key: "requestLoadCollectionItems") { Maybe<[ReadItem]>.just([]) }
        
        // when
        let loading = self.dummyRepository.requestLoadCollectionItems(collectionID: "some")
        let lists = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(lists.count, 1)
    }
    
    func testRepository_whenSignInAndLoadCollectionItemsFail_byRemoteFail() {
        // given
        let expect = expectation(description: "로그인 상태에서 내 아이템 로드시 리모트 실패면 에러방출")
        
        self.mockLocal.register(key: "fetchCollectionItems") { Maybe<[ReadItem]>.just([]) }
        self.mockRemote.register(key: "requestLoadCollectionItems") { Maybe<[ReadItem]>.error(LocalErrors.deserializeFail(nil)) }
        
        // when
        let loading = self.dummyRepository.requestLoadCollectionItems(collectionID: "some")
        let error = self.waitError(expect, for: loading)
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testRepository_whenAfterLoadCollectionItems_updateLocal() {
        // given
        let expect = expectation(description: "내 아이템 로드 이후에 로컬 업데이트")
        self.mockLocal.register(key: "fetchCollectionItems") { Maybe<[ReadItem]>.just([]) }
        self.mockRemote.register(key: "requestLoadCollectionItems") { Maybe<[ReadItem]>.just([]) }
        
        self.mockLocal.called(key: "updateReadItems") { _ in
            expect.fulfill()
        }
        
        // when
        self.dummyRepository.requestLoadCollectionItems(collectionID: "some")
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}

// MARK: - test sign in case: update case

extension RepositoryTests_ReadItem {
    
    func testRepository_whenSignInAndUpdateCollectionItems_withUpdateLocal() {
        // given
        let expect = expectation(description: "로그인 상태에서 collection item 업데이트 및 로컬 업데이트")
        expect.expectedFulfillmentCount = 2
        
        self.mockRemote.register(key: "requestUpdateReadCollection") { Maybe<Void>.just() }
        
        self.mockLocal.called(key: "updateReadItems") { _ in
            expect.fulfill()
        }
        
        // when
        let updating = self.dummyRepository.requestUpdateCollection(.init(name: "some"))
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_whenSignInAndUpdateReadLink_withUpdateLocal() {
        // given
        let expect = expectation(description: "로그인 상태에서 read link 업데이트 및 로컬 업데이트")
        expect.expectedFulfillmentCount = 2
        
        self.mockRemote.register(key: "requestUpdateReadLink") { Maybe<Void>.just() }
        
        self.mockLocal.called(key: "updateReadItems") { _ in
            expect.fulfill()
        }
        
        // when
        let updating = self.dummyRepository.requestUpdateLink(.init(link: "some"))
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
}


extension RepositoryTests_ReadItem {
    
    class DummyRepository: ReadItemRepository, ReadItemRepositryDefImpleDependency {
        
        let readItemRemote: ReadItemRemote
        let readItemLocal: ReadItemLocalStorage
        let disposeBag: DisposeBag = .init()
        
        init(remote: ReadItemRemote, local: ReadItemLocalStorage) {
            self.readItemRemote = remote
            self.readItemLocal = local
        }
    }
}