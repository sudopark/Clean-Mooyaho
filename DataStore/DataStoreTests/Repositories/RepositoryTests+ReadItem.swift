//
//  RepositoryTests+ReadItem.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/09/16.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

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
    func testRepository_loadMyItems_withoutSignin() {
        // given
        let expect = expectation(description: "내 아이템 패칭")
        
        self.mockLocal.register(key: "fetchMyItems") { Maybe<[ReadItem]>.just([]) }
        
        // when
        let loading = self.dummyRepository.requestLoadMyItems(for: nil)
        let items = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(items.count, 1)
    }
    
    func testRepository_fetchdMyItemsFail() {
        // given
        let expect = expectation(description: "내 아이템 패칭 실패시 빈값")
        
        self.mockLocal.register(key: "fetchMyItems") { Maybe<[ReadItem]>.error(LocalErrors.invalidData(nil)) }
        
        // when
        let loading = self.dummyRepository.requestLoadMyItems(for: nil)
        let items = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(items.first?.count, 0)
    }
    
    // load collectionItems
    func testRepository_fetchCollectionItems_withoutSignIn() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 특정 콜렉션 아이템 패칭")
        
        self.mockLocal.register(key: "fetchCollectionItems") { Maybe<[ReadItem]>.just([]) }
        
        // when
        let loading = self.dummyRepository.requestLoadCollectionItems(collectionID: "some")
        let items = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(items.count, 1)
    }
    
    func testRepository_fetchCollectionItemsFail() {
        // given
        let expect = expectation(description: "특정 콜렉션 아이템 패칭 실패시에 빈값")
        
        self.mockLocal.register(key: "fetchCollectionItems") { Maybe<[ReadItem]>.error(LocalErrors.invalidData(nil)) }
        
        // when
        let loading = self.dummyRepository.requestLoadCollectionItems(collectionID: "some")
        let items = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(items.first?.count, 0)
    }
    
    // udpate collection
    func testRepository_updateCollection_withoutSignin() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 특정 콜렉션 업데이트")
        
        self.mockLocal.register(key: "updateReadItems") { Maybe<Void>.just() }
        
        // when
        let updating = self.dummyRepository.requestUpdateCollection(.init(name: "some"))
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_updateCollectionFail() {
        // given
        let expect = expectation(description: "특정 콜렉션 업데이트 실패")
        
        self.mockLocal.register(key: "updateReadItems") { Maybe<Void>.error(LocalErrors.invalidData(nil)) }
        
        // when
        let updating = self.dummyRepository.requestUpdateCollection(.init(name: "some"))
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
        let saving = self.dummyRepository.requestUpdateLink(.init(link: "some"))
        let result: Void? = self.waitFirstElement(expect, for: saving.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_updateReadLinkFail() {
        // given
        let expect = expectation(description: "읽기링크 저장 실패")
        
        self.mockLocal.register(key: "updateReadItems") { Maybe<Void>.error(LocalErrors.invalidData(nil)) }
        
        // when
        let saving = self.dummyRepository.requestUpdateLink(.init(link: "some"))
        let error = self.waitError(expect, for: saving.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testRepository_fetchCollection() {
        // given
        let expect = expectation(description: "collection 패칭")
        self.mockLocal.register(key: "fetchCollection") { Maybe<ReadCollection?>.just(.init(name: "some")) }
        
        // when
        let loading = self.dummyRepository.requestLoadCollection("some")
        let collection = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertNotNil(collection)
    }
    
    func testRepository_fetchReadLink() {
        // given
        let expect = expectation(description: "read link 패칭")
        self.mockLocal.register(key: "fetchReadLink") { Maybe<ReadLink?>.just(.init(link: "url")) }
        
        // when
        let loading = self.dummyRepository.requestLoadReadLinkItem("some")
        let link = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertNotNil(link)
    }
    
    func testReposiotry_updateItem() {
        // given
        let expect = expectation(description: "아이템 업데이트")
        self.mockLocal.register(key: "updateItem") { Maybe<Void>.just() }
        
        // when
        let params = ReadItemUpdateParams(item: ReadLink(link: "some"))
            |> \.updatePropertyParams .~ [.remindTime(.now())]
        let updating = self.dummyRepository.requestUpdateItem(params)
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testReposiotry_updateItemFail() {
        // given
        let expect = expectation(description: "아이템 업데이트 실패")
        self.mockLocal.register(key: "updateItem") { Maybe<Void>.error(ApplicationErrors.invalid) }
        
        // when
        let params = ReadItemUpdateParams(item: ReadLink(link: "some"))
            |> \.updatePropertyParams .~ [.remindTime(.now())]
        let updating = self.dummyRepository.requestUpdateItem(params)
        let error: Error? = self.waitError(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testRepository_removeItem_withoutSignIn() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 아이템 삭제")
        self.mockLocal.register(key: "removeItem") { Maybe<Void>.just() }
        
        // when
        let removing = self.dummyRepository.requestRemove(item: ReadCollection(name: "some"))
        let result: Void? = self.waitFirstElement(expect, for: removing.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_removeItemFail_withoutSignIn() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 아이템 삭제 실패")
        self.mockLocal.register(key: "removeItem") { Maybe<Void>.error(ApplicationErrors.invalid) }
        
        // when
        let removing = self.dummyRepository.requestRemove(item: ReadCollection(name: "some"))
        let error = self.waitError(expect, for: removing.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testRepository_suggesNextReadItemWithoutSignIn() {
        // given
        let expect = expectation(description: "로그인 안한상태에서 다음 읽을아이템 추천")
        self.mockLocal.register(key: "suggestNextReadItems") {
            Maybe<[ReadItem]>.just([ReadCollection(name: "some")])
        }
        
        // when
        let suggesting = self.dummyRepository.requestSuggestNextReadItems(for: nil, size: 10)
        let items = self.waitFirstElement(expect, for: suggesting.asObservable())
        
        // then
        XCTAssertEqual(items?.count, 1)
    }
    
    func testReposiotry_requestLoadItemsWithIDs_withoutSignIn() {
        // given
        let expect = expectation(description: "로그인 안한상태에서 아이템 아이디로 아이템 로드")
        self.mockLocal.register(key: "fetchMathingItems") {
            Maybe<[ReadItem]>.just([ReadCollection(uid: "s", name: "n", createdAt: .now(), lastUpdated: .now())])
        }
        
        // when
        let loading = self.dummyRepository.requestLoadItems(ids: ["s"])
        let items = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertEqual(items?.count, 1)
    }
    
    func testReposiotry_refreshFavoriteItemIDs_withoutSignIn() {
        // given
        let expect = expectation(description: "로그아웃상태에서 즐겨찾는 아이템 목록 로드")
        self.mockLocal.register(key: "fetchFavoriteItemIDs") {
            Maybe<[String]>.just(["some"])
        }
        
        // when
        let refreshing = self.dummyRepository.requestRefreshFavoriteItemIDs()
        let ids = self.waitFirstElement(expect, for: refreshing.asObservable())
        
        // then
        XCTAssertEqual(ids?.count, 1)
    }
    
    func testRespository_toggleFavoriteIDs_withoutSignIn() {
        // given
        let expect = expectation(description: "로그인 안한상태에서 즐겨찾는 목록 토글링")
        
        // when
        let toggling = self.dummyRepository.toggleItemIsFavorite("some", toOn: true)
        let result: Void? = self.waitFirstElement(expect, for: toggling.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testReposiotry_loadCurrentReadingLinks() {
        // given
        let expect = expectation(description: "현재 읽고있는 링트 로드")
        self.mockLocal.register(key: "readingLinkItemIDs") {
            return ["some"]
        }
        self.mockLocal.register(key: "fetchMathingItems") {
            Maybe<[ReadItem]>.just([ReadLink(link: "some")])
        }
        
        // when
        let fethcing = self.dummyRepository.fetchUserReadingLinks()
        let items = self.waitFirstElement(expect, for: fethcing.asObservable())
        
        // then
        XCTAssertEqual(items?.count, 1)
    }
    
    func testResposiotry_updateIsReading() {
        // given
        let expect = expectation(description: "현재 읽고있음 업데이트")
        self.mockLocal.called(key: "updateLinkItemIsReading") { any in
            guard let isReading = any as? Bool, isReading else { return }
            expect.fulfill()
        }
        
        // when
        self.dummyRepository.updateLinkItemIsReading("some")
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testRepository_whenUpdateReadlinkAndIsRed_removeFromCurrentReadingList() {
        // given
        let expect = expectation(description: "현재 읽고있음 업데이트")
        self.mockLocal.register(key: "updateReadItems") { Maybe<Void>.just() }
        self.mockLocal.called(key: "updateLinkItemIsReading") { any in
            guard let isReading = any as? Bool, isReading == false else { return }
            expect.fulfill()
        }
        
        // when
        let item = ReadLink(link: "some") |> \.isRed .~ true
        self.dummyRepository.requestUpdateLink(item)
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
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
    
    func testRepository_whenSignInAndAfterLoadMyItems_updateLocal() {
        // given
        let expect = expectation(description: "내 아이템 로드 이후에 로컬 업데이트")
        
        self.mockLocal.register(key: "fetchMyItems") { Maybe<[ReadItem]>.just([]) }
        self.mockRemote.register(key: "requestLoadMyItems") { Maybe<[ReadItem]>.just([]) }
        
        self.mockLocal.called(key: "overwriteMyItems") { _ in
            expect.fulfill()
        }
        
        // when
        self.dummyRepository.requestLoadMyItems(for: "some")
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testRepository_whenSignInAndLoadMyItems_localFirstAndRemoteWithIgnoreLocalError() {
        // given
        let expect = expectation(description: "로그인 상태에서 내 아이템 로드시 로컬 패칭 에러는 빈값 반환 이후 리모트 로드")
        expect.expectedFulfillmentCount = 2
        
        self.mockLocal.register(key: "fetchMyItems") { Maybe<[ReadItem]>.error(LocalErrors.deserializeFail(nil)) }
        self.mockRemote.register(key: "requestLoadMyItems") { Maybe<[ReadItem]>.just([ReadLink.init(link: "some")]) }
        
        // when
        let loading = self.dummyRepository.requestLoadMyItems(for: "some")
        let lists = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(lists.first?.count, 0)
        XCTAssertEqual(lists.last?.count, 1)
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
    
    func testRepository_whenSignInAndAfterLoadCollectionItems_updateLocal() {
        // given
        let expect = expectation(description: "콜렉션 아이템 로드 이후에 로컬 업데이트")
        
        self.mockLocal.register(key: "fetchCollectionItems") { Maybe<[ReadItem]>.just([]) }
        self.mockRemote.register(key: "requestLoadCollectionItems") { Maybe<[ReadItem]>.just([]) }
        
        self.mockLocal.called(key: "overwriteCollectionItems") { _ in
            expect.fulfill()
        }
        
        // when
        self.dummyRepository.requestLoadCollectionItems(collectionID: "some")
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testRepository_whenSignInAndLoadCollectionItems_localFirstAndRemoteWithIgnoreLocalError() {
        // given
        let expect = expectation(description: "로그인 상태에서 내 아이템 로드시 로컬 패칭 에러는 빈값 반환 이후 리모트 로드")
        expect.expectedFulfillmentCount = 2
        
        self.mockLocal.register(key: "fetchCollectionItems") { Maybe<[ReadItem]>.error(LocalErrors.deserializeFail(nil)) }
        self.mockRemote.register(key: "requestLoadCollectionItems") { Maybe<[ReadItem]>.just([ReadLink.init(link: "some")]) }
        
        // when
        let loading = self.dummyRepository.requestLoadCollectionItems(collectionID: "some")
        let lists = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(lists.first?.count, 0)
        XCTAssertEqual(lists.last?.count, 1)
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
    
    func testRepository_loadCollectionWithSignedIn() {
        // given
        let expect = expectation(description: "로그인상태에서 콜렉션 로드")
        expect.expectedFulfillmentCount = 2
        self.mockLocal.register(key: "fetchCollection") { Maybe<ReadCollection?>.just(.init(name: "some")) }
        self.mockRemote.register(key: "requestLoadCollection") { Maybe<ReadCollection>.just(.init(name: "some")) }
        
        // when
        let loading = self.dummyRepository.requestLoadCollection("c")
        let colletions = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(colletions.count, 2)
    }
    
    func testRepository_loadCollectionWithSignedIn_ignoreLocalError() {
        // given
        let expect = expectation(description: "로그인상태에서 콜렉션 로드시에 로컬에러는 무시")
        self.mockLocal.register(key: "fetchCollection") { Maybe<ReadCollection?>.error(ApplicationErrors.invalid) }
        self.mockRemote.register(key: "requestLoadCollection") { Maybe<ReadCollection>.just(.init(name: "some")) }
        
        // when
        let loading = self.dummyRepository.requestLoadCollection("c")
        let colletions = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(colletions.count, 1)
    }
    
    func testRepository_whenAfterLoadCollectionFromRemote_updateLocal() {
        // given
        let expect = expectation(description: "remote에서 콜렉션 로드시에 로컬 업데이트")
        expect.expectedFulfillmentCount = 2
        self.mockLocal.register(key: "fetchCollection") { Maybe<ReadCollection?>.just(nil) }
        self.mockRemote.register(key: "requestLoadCollection") { Maybe<ReadCollection>.just(.init(name: "some")) }
        
        self.mockLocal.called(key: "updateReadItems") { _ in
            expect.fulfill()
        }
        
        // when
        let loading = self.dummyRepository.requestLoadCollection("c")
        let colletions = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(colletions.count, 1)
    }
    
    func testRepository_loadReadLinkWithSignedIn() {
        // given
        let expect = expectation(description: "로그인상태에서 read link 로드")
        expect.expectedFulfillmentCount = 2
        self.mockLocal.register(key: "fetchReadLink") { Maybe<ReadLink?>.just(.init(link: "url")) }
        self.mockRemote.register(key: "requestLoadReadLink") { Maybe<ReadLink>.just(.init(link: "url")) }
        
        // when
        let loading = self.dummyRepository.requestLoadReadLinkItem("some")
        let links = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(links.count, 2)
    }
    
    func testRepository_loadReadLinkWithSignedIn_ignoreLocalError() {
        // given
        let expect = expectation(description: "로그인상태에서 read link 로드시에 로컬에러는 무시")
        self.mockLocal.register(key: "fetchReadLink") { Maybe<ReadLink?>.error(ApplicationErrors.invalid) }
        self.mockRemote.register(key: "requestLoadReadLink") { Maybe<ReadLink>.just(.init(link: "url")) }
        
        // when
        let loading = self.dummyRepository.requestLoadReadLinkItem("some")
        let links = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(links.count, 1)
    }
    
    func testRepository_whenAfterLoadReadLinkFromRemote_updateLocal() {
        // given
        let expect = expectation(description: "remote에서 read link 로드시에 로컬 업데이트")
        expect.expectedFulfillmentCount = 2
        self.mockLocal.register(key: "fetchReadLink") { Maybe<ReadLink?>.just(nil) }
        self.mockRemote.register(key: "requestLoadReadLink") { Maybe<ReadLink>.just(.init(link: "url")) }
        
        self.mockLocal.called(key: "updateReadItems") { _ in
            expect.fulfill()
        }
        
        // when
        let loading = self.dummyRepository.requestLoadReadLinkItem("some")
        let links = self.waitElements(expect, for: loading)
        
        // then
        XCTAssertEqual(links.count, 1)
    }
    
    func testRepository_removeItem_withSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 아이템 삭제")
        self.mockRemote.register(key: "requestRemoveItem") { Maybe<Void>.just() }
        self.mockLocal.register(key: "removeItem") { Maybe<Void>.just() }
        
        // when
        let removing = self.dummyRepository.requestRemove(item: ReadCollection(name: "some"))
        let result: Void? = self.waitFirstElement(expect, for: removing.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testReposisoty_whenSignInAndRemoveItemFailOnLocal_ignore() {
        // given
        let expect = expectation(description: "로그인 상태에서 아이템 삭제시에 로컬에러는 무시")
        self.mockRemote.register(key: "requestRemoveItem") { Maybe<Void>.just() }
        self.mockLocal.register(key: "removeItem") { Maybe<Void>.error(ApplicationErrors.invalid) }
        
        // when
        let removing = self.dummyRepository.requestRemove(item: ReadCollection(name: "some"))
        let result: Void? = self.waitFirstElement(expect, for: removing.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_removeItemFail_whenSignIn() {
        // given
        // given
        let expect = expectation(description: "로그인 상태에서 아이템 삭제 실패")
        self.mockRemote.register(key: "requestRemoveItem") { Maybe<Void>.error(ApplicationErrors.invalid) }
        self.mockLocal.register(key: "removeItem") { Maybe<Void>.just() }
        
        // when
        let removing = self.dummyRepository.requestRemove(item: ReadCollection(name: "some"))
        let error = self.waitError(expect, for: removing.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testRepository_whenAfterRemoveLinkItem_removeMemo() {
        // given
        let expect = expectation(description: "링크 아이템 삭제 이후에 메모도 같이 삭제")
        self.mockRemote.register(key: "requestRemoveItem") { Maybe<Void>.just() }
        self.mockLocal.register(key: "removeItem") { Maybe<Void>.just() }
        
        // when
        let removing = self.dummyRepository.requestRemove(item: ReadLink(link: "some"))
        let _: Void? = self.waitFirstElement(expect, for: removing.asObservable())
            
        // then
        XCTAssertEqual(self.dummyRepository.didRemoveMemoRequested, true)
    }
    
    func testReposisotry_whenAfterRemoveCollectionItem_notRequestRemoveMemo() {
        // given
        let expect = expectation(description: "코렉션 아이템 삭제 이후에 메모도 같이 삭제 안함")
        self.mockRemote.register(key: "requestRemoveItem") { Maybe<Void>.just() }
        self.mockLocal.register(key: "removeItem") { Maybe<Void>.just() }
        
        // when
        let removing = self.dummyRepository.requestRemove(item: ReadCollection(name: "some"))
        let _: Void? = self.waitFirstElement(expect, for: removing.asObservable())
            
        // then
        XCTAssertEqual(self.dummyRepository.didRemoveMemoRequested, false)
    }
}

// MARK: - test sign in case: update case

extension RepositoryTests_ReadItem {
    
    func testRepository_whenSignInAndUpdateCollectionItems_withUpdateLocal() {
        // given
        let expect = expectation(description: "로그인 상태에서 collection item 업데이트 및 로컬 업데이트")
        
        self.mockRemote.register(key: "requestUpdateReadCollection") { Maybe<Void>.just() }
        self.mockLocal.register(key: "updateReadItems") { Maybe<Void>.just() }
        
        // when
        let updating = self.dummyRepository.requestUpdateCollection(.init(name: "some"))
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepository_whenSignInAndUpdateReadLink_withUpdateLocal() {
        // given
        let expect = expectation(description: "로그인 상태에서 read link 업데이트 및 로컬 업데이트")
        
        self.mockRemote.register(key: "requestUpdateReadLink") { Maybe<Void>.just() }
        self.mockLocal.register(key: "updateReadItems") { Maybe<Void>.just() }
        
        // when
        let updating = self.dummyRepository.requestUpdateLink(.init(link: "some"))
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testReposiotry_updateItemWithSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 아이템 업데이트")
        self.mockLocal.register(key: "updateItem") { Maybe<Void>.just() }
        self.mockRemote.register(key: "requestUpdateItem") { Maybe<Void>.just() }
        
        // when
        let params = ReadItemUpdateParams(item: ReadLink(link: "some"))
            |> \.updatePropertyParams .~ [.remindTime(.now())]
        let updating = self.dummyRepository.requestUpdateItem(params)
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testReposiotry_whenUpdateItemInLocalFailWithSignIn_ignore() {
        // given
        let expect = expectation(description: "로그인 상태에서 아이템 업데이트 로컬 실패는 무시")
        self.mockLocal.register(key: "updateItem") { Maybe<Void>.error(ApplicationErrors.invalid) }
        self.mockRemote.register(key: "requestUpdateItem") { Maybe<Void>.just() }
        
        // when
        let params = ReadItemUpdateParams(item: ReadLink(link: "some"))
            |> \.updatePropertyParams .~ [.remindTime(.now())]
        let updating = self.dummyRepository.requestUpdateItem(params)
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testReposiotry_updateItemFailWithSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 아이템 업데이트 실패")
        self.mockLocal.register(key: "updateItem") { Maybe<Void>.just() }
        self.mockRemote.register(key: "requestUpdateItem") { Maybe<Void>.error(ApplicationErrors.invalid) }
        
        // when
        let params = ReadItemUpdateParams(item: ReadLink(link: "some"))
            |> \.updatePropertyParams .~ [.remindTime(.now())]
        let updating = self.dummyRepository.requestUpdateItem(params)
        let error: Error? = self.waitError(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
}

extension RepositoryTests_ReadItem {
    
    func testRepository_findItem_andExistsOnLocal() {
        // given
        let expect = expectation(description: "로컬에서 url에 해당하는 아이템 찾음")
        self.mockLocal.register(key: "findLinkItem") { Maybe<ReadLink?>.just(ReadLink(link: "some")) }
        
        // when
        let finding = self.dummyRepository.requestFindLinkItem(using: "some")
        let link = self.waitFirstElement(expect, for: finding.asObservable())
        
        // then
        XCTAssertNotNil(link)
    }
    
    func testRepository_findItem_andExistsOnRemote() {
        // given
        let expect = expectation(description: "리모트에서 url에 해당하는 아이템 찾음")
        self.mockLocal.register(key: "findLinkItem") { Maybe<ReadLink?>.just(nil) }
        self.mockRemote.register(key: "requestFindLinkItem") { Maybe<ReadLink?>.just(ReadLink(link: "some")) }
        
        // when
        let finding = self.dummyRepository.requestFindLinkItem(using: "some")
        let link = self.waitFirstElement(expect, for: finding.asObservable())
        
        // then
        XCTAssertNotNil(link)
    }
    
    func testRepository_findItemAndLocalErrror_andExistsOnRemote() {
        // given
        let expect = expectation(description: "로컬에서 찾기 실패 이후에 리모트에서 url에 해당하는 아이템 찾음")
        self.mockLocal.register(key: "findLinkItem") { Maybe<ReadLink?>.error(ApplicationErrors.invalid) }
        self.mockRemote.register(key: "requestFindLinkItem") { Maybe<ReadLink?>.just(ReadLink(link: "some")) }
        
        // when
        let finding = self.dummyRepository.requestFindLinkItem(using: "some")
        let link = self.waitFirstElement(expect, for: finding.asObservable())
        
        // then
        XCTAssertNotNil(link)
    }
    
    func testRepository_findItem_andFindFromRemoteFail_isError() {
        // given
        let expect = expectation(description: "리모트에서 url에 해당하는 아이템 찾기 실패시 에러")
        self.mockLocal.register(key: "findLinkItem") { Maybe<ReadLink?>.just(nil) }
        self.mockRemote.register(key: "requestFindLinkItem") { Maybe<ReadLink?>.error(ApplicationErrors.invalid) }
        
        // when
        let finding = self.dummyRepository.requestFindLinkItem(using: "some")
        let error = self.waitError(expect, for: finding.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testReposotory_whenFindItemFromRemote_updateLocal() {
        // given
        let expect = expectation(description: "리모트에서 url에 해당하는 아이템 찾은 이후 로컬 업데이트")
        self.mockLocal.register(key: "findLinkItem") { Maybe<ReadLink?>.just(nil) }
        self.mockRemote.register(key: "requestFindLinkItem") { Maybe<ReadLink?>.just(ReadLink(link: "some")) }
        
        self.mockLocal.called(key: "updateReadItems") { _ in
            expect.fulfill()
        }
        
        // when
        self.dummyRepository.requestFindLinkItem(using: "some")
            .subscribe()
            .disposed(by: self.disposeBag)
        
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testRepository_suggesNextReadItemWithSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 다음 읽을아이템 추천")
        self.mockRemote.register(key: "requestSuggestNextReadItems") {
            Maybe<[ReadItem]>.just([ReadCollection(name: "some")])
        }
        
        // when
        let suggesting = self.dummyRepository.requestSuggestNextReadItems(for: "some", size: 10)
        let items = self.waitFirstElement(expect, for: suggesting.asObservable())
        
        // then
        XCTAssertEqual(items?.count, 1)
    }
    
    func testReposiotry_requestLoadItemsWithIDs_withSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 아이템 아이디로 아이템 로드시에 로컬에 없는것만 리모트에서 불러옴")
        self.mockLocal.register(key: "fetchMathingItems") {
            Maybe<[ReadItem]>.just([ReadCollection(uid: "1", name: "nn1", createdAt: .now(), lastUpdated: .now())])
        }
        self.mockRemote.register(key: "requestLoadItems") {
            Maybe<[ReadItem]>.just([ReadCollection(uid: "2", name: "nn2", createdAt: .now(), lastUpdated: .now())])
        }
        
        // when
        let loading = self.dummyRepository.requestLoadItems(ids: ["1", "2"])
        let items = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertEqual(items?.count, 2)
    }
    
    func testReposiotry_refreshFavoriteItemIDs_withSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 즐겨찾는 아이템 목록 로드")
        expect.expectedFulfillmentCount = 3
        self.mockLocal.register(key: "fetchFavoriteItemIDs") {
            Maybe<[String]>.just(["some"])
        }
        self.mockRemote.register(key: "requestLoadFavoriteItemIDs") {
            Maybe<[String]>.just(["some"])
        }
        self.mockLocal.called(key: "replaceFavoriteItemIDs") { _ in expect.fulfill() }
        
        // when
        let refreshing = self.dummyRepository.requestRefreshFavoriteItemIDs()
        let idLists = self.waitElements(expect, for: refreshing)
        
        // then
        XCTAssertEqual(idLists.count, 2)
    }
    
    func testRespository_toggleFavoriteIDs_withSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 즐겨찾는 목록 토글링")
        self.mockRemote.register(key: "requestToggleFavoriteItemID") { Maybe<Void>.just() }
        
        // when
        let toggling = self.dummyRepository.toggleItemIsFavorite("some", toOn: true)
        let result: Void? = self.waitFirstElement(expect, for: toggling.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRespository_whenToggleFavoriteIDsWithSignIn_updateLocal() {
        // given
        let expect = expectation(description: "로그인 상태에서 즐겨찾는 목록 토글링시에 로컬도 업데이트")
        self.mockRemote.register(key: "requestToggleFavoriteItemID") { Maybe<Void>.just() }
        self.mockLocal.called(key: "toggleItemIsFavorite") { _ in
            expect.fulfill()
        }
        
        // when
        self.dummyRepository.toggleItemIsFavorite("some", toOn: true)
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


extension RepositoryTests_ReadItem {
    
    func testRepository_loadIsReloadNeed() {
        // given
        self.mockLocal.register(key: "fetchReloadNeedCollectionIDs") { ["some"] }
        
        // when
        let needIDs = self.dummyRepository.reloadNeedCollectionIDs()
        
        // then
        XCTAssertEqual(needIDs, ["some"])
    }

    func testRepository_updateIsReloadNeed() {
        // given
        let expect = expectation(description: "reload 필요여부 업데이트")
        self.mockLocal.called(key: "updateIsReloadNeedCollectionIDs") { args in
            guard let ids = args as? [String], ids == ["some"] else { return }
            expect.fulfill()
        }
        
        // when
        self.dummyRepository.updateIsReloadNeedCollectionIDs(["some"])
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


extension RepositoryTests_ReadItem {
    
    class DummyRepository: ReadItemRepository, ReadItemRepositryDefImpleDependency, ReadLinkMemoRepository, ReadLinkMemoRepositoryDefImpleDependency {
        
        let mockLocal: MockLocal
        let mockRemote: MockRemote
        
        var memoRemote: ReadLinkMemoRemote {
            return self.mockRemote
        }
        
        var memoLocal: ReadLinkMemoLocalStorage {
            return self.mockLocal
        }
        
        var readItemRemote: ReadItemRemote {
            return self.mockRemote
        }
        var readItemLocal: ReadItemLocalStorage {
            return self.mockLocal
        }
        
        let disposeBag: DisposeBag = .init()
        
        init(remote: MockRemote, local: MockLocal) {
            self.mockRemote = remote
            self.mockLocal = local
        }
        
        var didRemoveMemoRequested: Bool = false
        func requestRemoveMemo(for linkItemID: String) -> Maybe<Void> {
            self.didRemoveMemoRequested = true
            return .just()
        }
    }
}
