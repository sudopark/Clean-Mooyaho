//
//  SuggestReadViewModelTests.swift
//  SuggestSceneTests
//
//  Created by sudo.park on 2021/11/28.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

@testable import SuggestScene


class SuggestReadViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyRouter: SpyRouter!
    var spyReadCollectionMainInteractor: SpyReadCollectionMainInteractor!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyRouter = nil
        self.spyReadCollectionMainInteractor = nil
    }
    
    private var dummyTodoRead: [ReadItem] {
        return (0..<3).map { ReadCollection.dummy($0) } + (3..<5).map { ReadLink.dummy($0) }
    }
    
    private var dumnyFavoriteIDs: [String] {
        return (100..<103).map { "id:\($0)" }
    }
    
    private var dummyLatestLinks: [ReadLink] {
        return (50..<53).map {
            ReadLink(uid: "l:\($0)", link: "link:\($0)", createAt: .now(), lastUpdated: .now())
        }
    }
    
    private func makeViewModel(isAllEmpty: Bool = false) -> SuggestReadViewModel {
        
        let scenario = StubReadItemUsecase.Scenario()
            |> \.suggestNextResult .~ (.success(isAllEmpty ? [] : self.dummyTodoRead))
            |> \.loadFavoriteIDsResult .~ (.success(isAllEmpty ? [] : self.dumnyFavoriteIDs))
            |> \.loadContinueLinks .~ (.success(isAllEmpty ? [] : self.dummyLatestLinks))
        let readUsecase = StubReadItemUsecase(scenario: scenario)
        let categoryUsecase = StubItemCategoryUsecase()
        
        let router = SpyRouter()
        self.spyRouter = router
        
        let collectionInteractor = SpyReadCollectionMainInteractor()
        self.spyReadCollectionMainInteractor = collectionInteractor
        
        return SuggestReadViewModelImple(readItemLoadUsecase: readUsecase,
                                         favoriteItemUsecase: readUsecase,
                                         categoriesUsecase: categoryUsecase,
                                         router: router,
                                         listener: nil,
                                         readCollectionMainInteractor: collectionInteractor)
    }
}


extension SuggestReadViewModelTests {

    // 리스트 아이템 구성
    func testViewModel_provideSuggestCellViewModels() {
        // given
        let expect = expectation(description: "읽을목록 서제스트 제공")
        let viewModel = self.makeViewModel()
        
        // when
        let source = viewModel.sections
            .skip(while: { sections in
                let favSection = sections[safe: 1]
                let hasFavCell = favSection?.cellViewModels.first is ReadCollectionCellViewModel
                return hasFavCell != true
            })
        let sections = self.waitFirstElement(expect, for: source) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(sections?.count, 3)
        XCTAssertEqual(sections?[safe: 0]?.type, .todoRead)
        XCTAssertEqual(sections?[safe: 0]?.cellViewModels.isNotEmpty, true)
        XCTAssertEqual(sections?[safe: 1]?.type, .favotire)
        XCTAssertEqual(sections?[safe: 1]?.cellViewModels.isNotEmpty, true)
        XCTAssertEqual(sections?[safe: 2]?.type, .continueRead)
        XCTAssertEqual(sections?[safe: 2]?.cellViewModels.isNotEmpty, true)
    }
    
    // 섹션 비어있을때는 엠티셀 노출
    func testViewModel_whenSuggestNoItem_provideSuggestCellViewModelsWithEmptyCell() {
        // given
        let expect = expectation(description: "읽을목록 서제스트 할거없을때 엠티셀 제공")
        let viewModel = self.makeViewModel(isAllEmpty: true)
        
        // when
        let source = viewModel.sections
        let sections = self.waitFirstElement(expect, for: source) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(sections?.count, 3)
        XCTAssertEqual(sections?[safe: 0]?.type, .todoRead)
        XCTAssertEqual(sections?[safe: 0]?.cellViewModels.count, 1)
        XCTAssertEqual(sections?[safe: 0]?.cellViewModels.first is SuggestEmptyCellViewModel, true)
        XCTAssertEqual(sections?[safe: 1]?.type, .favotire)
        XCTAssertEqual(sections?[safe: 1]?.cellViewModels.count, 1)
        XCTAssertEqual(sections?[safe: 1]?.cellViewModels.first is SuggestEmptyCellViewModel, true)
        XCTAssertEqual(sections?[safe: 2]?.type, .continueRead)
        XCTAssertEqual(sections?[safe: 2]?.cellViewModels.count, 1)
        XCTAssertEqual(sections?[safe: 2]?.cellViewModels.first is SuggestEmptyCellViewModel, true)
    }
}

extension SuggestReadViewModelTests {
    
    // 콜렉션으로 이동
    func testViewModel_jumpToCollection() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.selectCollection("some")
        
        // then
        XCTAssertEqual(self.spyReadCollectionMainInteractor.didJumpToCollection, true)
    }
    
    // 링크 디테일로 이동
    func testViewModel_showLinkDetail() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.selectReadLink("some")
        
        // then
        XCTAssertEqual(self.spyRouter.didShowLinkDetail, true)
    }
    
    // 즐겨찾는 목록으로 이동
    func testViewModel_viewAllFavorites() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.viewAllFavoriteRead()
        
        // then
        XCTAssertEqual(self.spyRouter.didShowAllFavorite, true)
    }
}


extension SuggestReadViewModelTests {
    
    class SpyRouter: SuggestReadRouting {
     
        var didShowLinkDetail: Bool?
        func showLinkDetail(_ linkID: String) {
            self.didShowLinkDetail = true
        }
        
        var didShowAllTodoRead: Bool?
        func showAllTodoReadItems() {
            self.didShowAllTodoRead = true
        }
        
        var didShowAllFavorite: Bool?
        func showAllFavoriteItemList() {
            self.didShowAllFavorite = true
        }
        
        var didShowAllLatest: Bool?
        func showAllLatestReadItems() {
            self.didShowAllLatest = true
        }
    }
    
    
    class SpyReadCollectionMainInteractor: ReadCollectionMainSceneInteractable {
        func addNewCollectionItem() { }
        
        func addNewReadLinkItem() { }
        
        func addNewReaedLinkItem(with url: String) { }
        
        func switchToSharedCollection(_ collection: SharedReadCollection) { }
        
        func switchToMyReadCollections() { }
        
        var didJumpToCollection: Bool?
        func jumpToCollection(_ collectionID: String?) {
            self.didJumpToCollection = true
        }
        
        var rootType: CollectionRoot = .myCollections
    }
}
