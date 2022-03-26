//
//  AllSharedCollectionsViewModelTests.swift
//  DiscoveryScene
//
//  Created by sudo.park on 2021/12/08.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

@testable import DiscoveryScene


class AllSharedCollectionsViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyRouter: SpyRouter!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
    }
    
    private var dummyCollections: [[SharedReadCollection]] {
        return (0..<10).map { page in
            return (page*10..<page*10+10).map { SharedReadCollection.dummy($0) }
        }
    }
    
    private func makeViewModel() -> AllSharedCollectionsViewModel {
        let router = SpyRouter()
        self.spyRouter = router
        
        let pagingUsecase = StubSharedCollectionPagingUsecase()
            |> \.loadedCollectionLists .~ self.dummyCollections
        let updateUsecase = StubShareItemUsecase()
        let memberUsecase = BaseStubMemberUsecase()
        let categoryUsecase = StubItemCategoryUsecase()
        
        return AllSharedCollectionsViewModelImple(pagingUsecase: pagingUsecase,
                                                  updateUsecase: updateUsecase,
                                                  memberUsecase: memberUsecase,
                                                  categoryUsecase: categoryUsecase,
                                                  router: router, listener: nil)
    }
}


extension AllSharedCollectionsViewModelTests {
    
    func testViewModel_loadSharedCollections() {
        // given
        let expect = expectation(description: "공유받은 콜렉션 로드")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel()
        
        // when
        let collectionLists = self.waitElements(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollections()
            viewModel.loadMoreCollections()
        }
        
        // then
        let collectionCounts = collectionLists.map { $0.count }
        XCTAssertEqual(collectionCounts, [10, 20])
    }
    
    func testViewModel_wheSelectCollection_switchToSharedCollection() {
        // given
        let expect = expectation(description: "공유받은 콜렉션 조회")
        let viewModel = self.makeViewModel()
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollections()
        }
        let cellViewModel = cvms?.randomElement()
        viewModel.selectCollection(sharedID: cellViewModel?.shareID ?? "")
        
        // then
        XCTAssertEqual(self.spyRouter.didSwitchToSharedCollection != nil, true)
    }
    
    func testViewModel_whenRemoveCollection_askAndRemoveFromList() {
        // given
        let expect = expectation(description: "아이템 삭제 이후에 목록에서 제거")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel()
        let dummy = self.dummyCollections.first?.randomElement()
        
        // when
        let cvmLists = self.waitElements(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollections()
            viewModel.removeCollection(sharedID: dummy?.shareID ?? "")
        }
        
        // then
        XCTAssertEqual(self.spyRouter.didAlertConfirm, true)
        let ids = cvmLists.map { $0.map { $0.shareID } }
        XCTAssertEqual(ids.count, 2)
        XCTAssertEqual(ids[safe: 0]?.contains(dummy?.shareID ?? ""), true)
        XCTAssertEqual(ids[safe: 1]?.contains(dummy?.shareID ?? ""), false)
    }
}


extension AllSharedCollectionsViewModelTests {
    
    class SpyRouter: AllSharedCollectionsRouting {
        
        var didSwitchToSharedCollection: SharedReadCollection?
        func switchToSharedCollection(_ collection: SharedReadCollection) {
            self.didSwitchToSharedCollection = collection
        }
        
        var didAlertConfirm: Bool?
        func alertForConfirm(_ form: AlertForm) {
            didAlertConfirm = true
            form.confirmed?()
        }
    }
}
