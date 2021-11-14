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
                             shouldFailStopShare: Bool = false) -> ShareItemUsecaseImple {
        
        let dataStore = SharedDataStoreServiceImple()
        dataStore.save(Member.self, key: .currentMember, Member(uid: "some", nickName: nil, icon: nil))
        self.spySharedStore = dataStore
        
        let repository = StubShareItemRepository()
            |> \.shareCollectionResult .~ (shouldFailShare ? .failure(ApplicationErrors.invalid) : .success(self.dummySharedCollection))
            |> \.stopShareItemResult %~ { shouldFailStopShare ? .failure(ApplicationErrors.invalid) : $0 }
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
        let shared = self.waitFirstElement(expect, for: usecase.shareCollection(dummy).asObservable())
        
        // then
        XCTAssertNotNil(shared)
    }
    
    func testUsecase_shareItemFail() {
        // given
        let expect = expectation(description: "아이템 쉐어 실패")
        let usecase = self.makeUsecase(shouldFailShare: true)
        
        // when
        let dummy = ReadCollection.dummy(0, parent: nil)
        let error = self.waitError(expect, for: usecase.shareCollection(dummy).asObservable())
        
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
    
    func testUsecase_loadSharedCollectionByURL() {
        // given
        // when
        // then
    }
}
