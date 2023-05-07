//
//  FavoriteItemsViewModelTests.swift
//  ReadItemSceneTests
//
//  Created by sudo.park on 2021/12/01.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

import ReadItemScene

class FavoriteItemsViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyRouter: SpyRouter!
    var spyListener: SpyListener!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyRouter = nil
        self.spyListener = nil
    }
    
    private var dummyItems: [ReadItem] {
        return (0..<5).map { ReadCollection.dummy($0) } + (5..<100).map { ReadLink.dummy($0) }
    }
    
    private func makeViewModel() -> FavoriteItemsViewModel {
        
        let pagingUsecase = StubFavoritePagingUsecase()
            |> \.totalItems .~ self.dummyItems
        let categoryUsecase = StubItemCategoryUsecase()
        
        let router = SpyRouter()
        self.spyRouter = router
        
        let listener = SpyListener()
        self.spyListener = listener
        
        return FavoriteItemsViewModelImple(pagingUsecase: pagingUsecase,
                                           previewLoadUsecase: StubReadItemUsecase(),
                                           categoryUsecase: categoryUsecase,
                                           router: router, listener: listener)
    }
}


extension FavoriteItemsViewModelTests {
    
    // refresh로 아이템 구성
    func testViewModel_showList() {
        // given
        let expect = expectation(description: "즐겨찾는 아이템 구성")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel()
        
        // when
        let cvmLists = self.waitElements(expect, for: viewModel.cellViewModels) {
            viewModel.refreshList()
            viewModel.loadMore()
            viewModel.refreshList()
        }
        
        // then
        XCTAssertEqual(cvmLists.map { $0.count }, [10, 20, 10])
    }
    
    // collection 이동
    func testViewModel_moveToCollection() {
        // given
        let expect = expectation(description: "콜렉션 선택시 점프")
        let viewModel = self.makeViewModel()
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.refreshList()
        }
        viewModel.selectCollection(cvms?.first?.uid ?? "")
        
        // then
        XCTAssertEqual(self.spyListener.didJumpRequested, true)
    }
    
    // link로 이동
    func testViewModel_showLinkDetail() {
        // given
        let expect = expectation(description: "링크 선택시 상세내용 표시")
        let viewModel = self.makeViewModel()
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.refreshList()
        }
        viewModel.selectLink(cvms?.last?.uid ?? "")
        
        // then
        XCTAssertEqual(self.spyRouter.didShowLinkDetail, true)
    }
}


extension FavoriteItemsViewModelTests {
    
    final class SpyRouter: FavoriteItemsRouting, @unchecked Sendable {
        
        var didShowLinkDetail: Bool?
        func showLinkDetail(_ link: ReadLink) {
            self.didShowLinkDetail = true
        }
    }
    
    final class SpyListener: FavoriteItemsSceneListenable, @unchecked Sendable {
        
        var didJumpRequested: Bool?
        func favoriteItemsScene(didRequestJump collectionID: String?) {
            self.didJumpRequested = true
        }
    }
}
