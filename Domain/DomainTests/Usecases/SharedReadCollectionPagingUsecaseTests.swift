//
//  SharedReadCollectionPagingUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/12/07.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import UnitTestHelpKit

import Domain


class SharedReadCollectionPagingUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
    }
    
    private var totalIDs: [String] {
        return (0..<31).map { "id:\($0)" }
    }
    
    private func makeUsecase() -> SharedReadCollectionPagingUsecase {
        
        let respository = StubShareItemRepository()
            |> \.loadAllSharedCollectionIDsResult .~ .success(self.totalIDs)
        let store = SharedDataStoreServiceImple()
        
        return SharedReadCollectionPagingUsecaseImple(
            repository: respository,
            sharedDataStoreService: store
        )
    }
}


extension SharedReadCollectionPagingUsecaseTests {

    func testUsecase_loadCollectionsUntilEnd() {
        // given
        let expect = expectation(description: "마지막페이지까지 콜렉션 로드")
        expect.expectedFulfillmentCount = 4
        let usecase = self.makeUsecase()
        
        // when
        let collectionLists = self.waitElements(expect, for: usecase.collections, skip: 1) {
            usecase.reloadSharedCollections()       // 0..<10
            usecase.loadMoreSharedCollections()     // 10..<20
            usecase.loadMoreSharedCollections()     // 20..<30
            usecase.loadMoreSharedCollections()     // 30...31
            usecase.loadMoreSharedCollections()     // x
            usecase.loadMoreSharedCollections()     // x
        }
        
        // then
        let ids = collectionLists.map { $0.map { $0.shareID } }
        XCTAssertEqual(ids, [
            (0..<10).map { "id:\($0)" },
            (0..<20).map { "id:\($0)" },
            (0..<30).map { "id:\($0)" },
            (0..<31).map { "id:\($0)" }
        ])
    }
    
    func testUsecase_loadCollectionUntilPage2_andReloadFromStart() {
        // given
        let expect = expectation(description: "두번째페이지까지 로드 이후에 처음부터 다시 시작")
        expect.expectedFulfillmentCount = 3
        let usecase = self.makeUsecase()
        
        // when
        let collectionLists = self.waitElements(expect, for: usecase.collections, skip: 1) {
            usecase.reloadSharedCollections()       // 0..<10
            usecase.loadMoreSharedCollections()     // 10..<20
            usecase.reloadSharedCollections()       // 0..<10
        }
        
        // then
        let ids = collectionLists.map { $0.map { $0.shareID } }
        XCTAssertEqual(ids, [
            (0..<10).map { "id:\($0)" },
            (0..<20).map { "id:\($0)" },
            (0..<10).map { "id:\($0)" }
        ])
    }
    
    func testUsecase_whenRefreshing_updateIsRefreshing() {
        // given
        let expect = expectation(description: "refresh 중에는 refresh 상태 업데이트")
        expect.expectedFulfillmentCount = 3
        let usecase = self.makeUsecase()
        
        // when
        let isRefreshings = self.waitElements(expect, for: usecase.isRefreshing) {
            usecase.reloadSharedCollections()
        }
        
        // then
        XCTAssertEqual(isRefreshings, [false, true, false])
    }
}
