//
//  ShareItemUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import UnitTestHelpKit


class ShareItemUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spySharedStore: SharedDataStoreService!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spySharedStore = nil
    }
    
    private var dummySharedCollection: SharedReadCollection {
        return .dummy(0)
    }
    
    private func makeUsecase(shouldFailShare: Bool = false,
                             shouldFailStopShare: Bool = false,
                             shouldFailLoadSharedItem: Bool = false,
                             sharingCollectionIDs: [[String]] = []) -> ShareItemUsecaseImple {
        
        let dataStore = SharedDataStoreServiceImple()
        dataStore.save(Member.self, key: .currentMember, Member(uid: "some", nickName: nil, icon: nil))
        self.spySharedStore = dataStore
        
        let repository = StubShareItemRepository()
            |> \.shareCollectionResult .~ (shouldFailShare ? .failure(ApplicationErrors.invalid) : .success(self.dummySharedCollection))
            |> \.stopShareItemResult %~ { shouldFailStopShare ? .failure(ApplicationErrors.invalid) : $0 }
            |> \.loadSharedCollectionResult .~ (shouldFailLoadSharedItem ? .failure(ApplicationErrors.invalid) : .success(self.dummySharedCollection))
            |> \.loadMySharingCollectionIDsResults .~ sharingCollectionIDs
        return ShareItemUsecaseImple(shareRepository: repository,
                                     authInfoProvider: dataStore,
                                     sharedDataService: dataStore)
    }
}


// MARK: - start share or stop

extension ShareItemUsecaseTests {
    
    func testUsecase_shareItem() {
        // given
        let expect = expectation(description: "아이템 쉐어")
        let usecase = self.makeUsecase()
        
        // when
        let dummy = ReadCollection.dummy(0, parent: nil)
        let shared = self.waitFirstElement(expect, for: usecase.shareCollection(dummy.uid).asObservable())
        
        // then
        XCTAssertNotNil(shared)
    }
    
    func testUsecase_whenAfterShareItem_updateSharingIDList() {
        // given
        let expect = expectation(description: "아이템 공유하면 공유중인 콜렉션 아이디 목록 업데이트됨")
        let usecase = self.makeUsecase()
        
        // when
        let dummy = ReadCollection.dummy(0, parent: nil)
        let ids = self.waitFirstElement(expect, for: usecase.mySharingCollectionIDs) {
            usecase.shareCollection(dummy.uid)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertEqual(ids, [dummy.uid])
    }
    
    func testUsecase_shareItemFail() {
        // given
        let expect = expectation(description: "아이템 쉐어 실패")
        let usecase = self.makeUsecase(shouldFailShare: true)
        
        // when
        let dummy = ReadCollection.dummy(0, parent: nil)
        let error = self.waitError(expect, for: usecase.shareCollection(dummy.uid).asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testUsecase_stopShareItem() {
        // given
        let expect = expectation(description: "아이템 공유 중지")
        let usecase = self.makeUsecase()
        
        // when
        let stopping = usecase.stopShare(collection: "some")
        let result: Void? = self.waitFirstElement(expect, for: stopping.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testUsecase_whenAfterStopShareItem_updateSharingIDList() {
        // given
        let expect = expectation(description: "아이템 공유 중지 이후에 공유중인 콜렉션 아이디 목록 업데이트됨")
        expect.expectedFulfillmentCount = 2
        let dummy = ReadCollection.dummy(0, parent: nil)
        let usecase = self.makeUsecase(sharingCollectionIDs: [[dummy.uid]])
        usecase.refreshMySharingColletionIDs()
        
        // when
        let idLists = self.waitElements(expect, for: usecase.mySharingCollectionIDs) {
            usecase.stopShare(collection: dummy.uid)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertEqual(idLists, [[dummy.uid], []])
    }
    
    func testUsecase_stopShareItemFail() {
        // given
        let expect = expectation(description: "아이템 공유 중지 실패")
        let usecase = self.makeUsecase(shouldFailStopShare: true)
        
        // when
        let stopping = usecase.stopShare(collection: "some")
        let error = self.waitError(expect, for: stopping.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testUsecase_updateMySharingCollectionIDs() {
        // given
        let expect = expectation(description: "내가 공유중인 콜렉션 아이디 목록 로드")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase(sharingCollectionIDs: [["0"], ["0", "1"]])
        
        // when
        let idLists = self.waitElements(expect, for: usecase.mySharingCollectionIDs) {
            usecase.refreshMySharingColletionIDs()
            usecase.refreshMySharingColletionIDs()
        }
        
        // then
        XCTAssertEqual(idLists, [["0"], ["0", "1"]])
    }
}


// MARK: - load and handle shared

extension ShareItemUsecaseTests {
    
    func testUsecase_refreshLatestSharedCollection() {
        // given
        let expect = expectation(description: "최근 공유된 콜렉션 리프레쉬")
        let usecase = self.makeUsecase()
        
        // when
        let datKey = SharedDataKeys.latestSharedCollections.rawValue
        let source = self.spySharedStore.observe([SharedReadCollection].self, key: datKey)
        let collections = self.waitFirstElement(expect, for: source) {
            usecase.refreshLatestSharedReadCollection()
        }
        
        // then
        XCTAssertNotNil(collections)
    }
    
    func testUsecase_whenSignout_notRefreshLatestSharedCollections() {
        // given
        let expect = expectation(description: "로그아웃 상태에서는 공유받은 콜렉션 리프레쉬 안함")
        expect.isInverted = true
        let usecase = self.makeUsecase()
        
        // when
        self.spySharedStore.save(Member?.self, key: .currentMember, nil)
        let datKey = SharedDataKeys.latestSharedCollections.rawValue
        let source = self.spySharedStore.observe([SharedReadCollection].self, key: datKey)
        let collections = self.waitFirstElement(expect, for: source) {
            usecase.refreshLatestSharedReadCollection()
        }
        
        // then
        XCTAssertNil(collections)
    }
    
    func testUsecase_whenLoadMySharingItem_usePrefetched() {
        // given
        let expectWithoutCache = expectation(description: "캐시 없을때 로드")
        let expectWithCache = expectation(description: "내기 공유하는 콜렉션 로드시에 이미 로드한 데이터 활용")
        expectWithCache.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase()
        
        // when
        let load = usecase.loadMyharingCollection(for: "some")
        let collection1 = self.waitFirstElement(expectWithoutCache, for: load)
        
        let loadAgain = usecase.loadMyharingCollection(for: "some")
        let collections = self.waitElements(expectWithCache, for: loadAgain)
        
        // then
        XCTAssertNotNil(collection1)
        XCTAssertEqual(collections.count, 2)
    }
    
    func testUsecase_loadSharedCollectionByURL() {
        // given
        let expect = expectation(description: "공유 url로 아이템 로드")
        let usecase = self.makeUsecase()
        
        // when
        let url = "readminds://share/collection?id=some"
        let loading = usecase.loadSharedCollection(by: URL(string: url)!)
        let result = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testUsecase_whenInvalidShareItem_notLoadAndInvalidError() {
        // given
        let expect = expectation(description: "공유 url이 아닌경우 아무것도 안함")
        expect.isInverted = true
        let usecase = self.makeUsecase()
        
        // when
        let url = "readminds://invalid/url/address?id=some"
        let loading = usecase.loadSharedCollection(by: URL(string: url)!)
        let result = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertNil(result)
    }
    
    func testUsecase_whenSharedURLIsValidButFailtoLoadItem() {
        // given
        let expect = expectation(description: "공유된 아이템 로드 실패")
        let usecase = self.makeUsecase(shouldFailLoadSharedItem: true)
        
        // when
        let url = "readminds://share/collection?id=some"
        let loading = usecase.loadSharedCollection(by: URL(string: url)!)
        let error = self.waitError(expect, for: loading.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testUsecase_whenLoadSharedCollection_insertToLastestList() {
        // given
        let expect = expectation(description: "공유된 아이템 아이템 조회시에 최근 공유받은 목록 업데이트")
        let usecase = self.makeUsecase()
        
        // when
        let source = self.spySharedStore.observe([SharedReadCollection].self, key: SharedDataKeys.latestSharedCollections.rawValue)
        let collections = self.waitFirstElement(expect, for: source) {
            let url = "readminds://share/collection?id=some"
            usecase.loadSharedCollection(by: URL(string: url)!)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertEqual(collections?.map { $0.uid }, [self.dummySharedCollection.uid])
    }
    
    func testUsecase_whenLoadSharedCollectionAndAlreadyViewItem_updateToLastestList() {
        // given
        let expect = expectation(description: "이미 본적있는 공유된 아아템 url로 조회시에 공유받은 목록에서 최상위로 업데이트")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase()
        let oldList = [SharedReadCollection.dummy(1), self.dummySharedCollection]
        self.spySharedStore.save([SharedReadCollection].self, key: .latestSharedCollections, oldList)
        
        // when
        let source = self.spySharedStore.observe([SharedReadCollection].self, key: SharedDataKeys.latestSharedCollections.rawValue)
            .compactMap{ $0 }
        let collectionLists = self.waitElements(expect, for: source) {
            let url = "readminds://share/collection?id=\(self.dummySharedCollection.uid)"
            usecase.loadSharedCollection(by: URL(string: url)!)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        let ids = collectionLists.map { $0.map { $0.uid} }
        XCTAssertEqual(ids, [
            [SharedReadCollection.dummy(1).uid, self.dummySharedCollection.uid],
            [self.dummySharedCollection.uid, SharedReadCollection.dummy(1).uid]
            ]
        )
    }
}
