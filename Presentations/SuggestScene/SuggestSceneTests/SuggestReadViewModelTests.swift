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
    var stubReadUsecase: StubReadItemUsecase!
    var spyRouter: SpyRouter!
    var dummyListener: DummyListener!
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
        self.stubReadUsecase = readUsecase
        
        let categoryUsecase = StubItemCategoryUsecase()
        
        let router = SpyRouter()
        self.spyRouter = router
        
        let collectionInteractor = SpyReadCollectionMainInteractor()
        self.spyReadCollectionMainInteractor = collectionInteractor
        
        self.dummyListener = DummyListener()
        
        return SuggestReadViewModelImple(readItemUsecase: readUsecase,
                                         categoriesUsecase: categoryUsecase,
                                         router: router,
                                         listener: self.dummyListener,
                                         readCollectionMainInteractor: collectionInteractor)
    }
}


extension SuggestReadViewModelTests {

    // ????????? ????????? ??????
    func testViewModel_provideSuggestCellViewModels() {
        // given
        let expect = expectation(description: "???????????? ???????????? ??????")
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
    
    // ?????? ?????????????????? ????????? ??????
    func testViewModel_whenSuggestNoItem_provideSuggestCellViewModelsWithEmptyCell() {
        // given
        let expect = expectation(description: "???????????? ???????????? ??????????????? ????????? ??????")
        let viewModel = self.makeViewModel(isAllEmpty: true)
        
        // when
        let source = viewModel.sections
        let sections = self.waitFirstElement(expect, for: source) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(sections?.count, 2)
        XCTAssertEqual(sections?[safe: 0]?.type, .favotire)
        XCTAssertEqual(sections?[safe: 0]?.cellViewModels.count, 1)
        XCTAssertEqual(sections?[safe: 0]?.cellViewModels.first is SuggestEmptyCellViewModel, true)
        XCTAssertEqual(sections?[safe: 1]?.type, .continueRead)
        XCTAssertEqual(sections?[safe: 1]?.cellViewModels.count, 1)
        XCTAssertEqual(sections?[safe: 1]?.cellViewModels.first is SuggestEmptyCellViewModel, true)
    }
}

extension SuggestReadViewModelTests {
    
    // ??????????????? ??????
    func testViewModel_jumpToCollection() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.selectCollection("some")
        
        // then
        XCTAssertEqual(self.spyReadCollectionMainInteractor.didJumpToCollection, true)
    }
    
    // ?????? ???????????? ??????
    func testViewModel_showLinkDetail() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.selectReadLink("some")
        
        // then
        XCTAssertEqual(self.spyRouter.didShowLinkDetail, true)
    }
    
    // ???????????? ???????????? ??????
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
    
    func testViewModel_whenItemChangeToRead_removeFromTodoAndContibueReadingList() {
        // given
        let expect = expectation(description: "???????????? ????????? ?????????????????? ??????, ????????? ???????????? ??????")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel()
        
        let dummyTodo = self.dummyTodoRead.compactMap { $0 as? ReadLink }.last!
        let dummyContinue = self.dummyLatestLinks.randomElement()!
        
        // when
        let source = viewModel.sections.skip(while: { $0.count < 3 })
        let sections = self.waitElements(expect, for: source, skip: 2) {
            viewModel.refresh()
            let redItem1 = dummyTodo |> \.isRed .~ true
            self.stubReadUsecase.readItemUpdateMocking.onNext(.updated(redItem1))
            
            let redItem2 = dummyContinue |> \.isRed .~ true
            self.stubReadUsecase.readItemUpdateMocking.onNext(.updated(redItem2))
        }
        
        // then
        let cells1 = sections.first?.first?.cellViewModels
        XCTAssertEqual(cells1?.contains(where: { $0.uid == dummyTodo.uid }), false)
        let cells2 = sections.last?.last?.cellViewModels
        XCTAssertEqual(cells2?.contains(where: { $0.uid == dummyContinue.uid }), false)
    }
    
    func testViewModel_whenItemRemoved_removeFromSuggestList() {
        // given
        let expect = expectation(description: "???????????? ???????????? ?????? ??????????????? ??????")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel()
        
        let dummyTodo = self.dummyTodoRead.randomElement()!
        let dummyFavoriteID = self.dumnyFavoriteIDs.randomElement()!
        let dummyContinue = self.dummyLatestLinks.randomElement()!
        
        // when
        let source = viewModel.sections.skip(while: { $0.count < 3 })
        let sections = self.waitElements(expect, for: source, skip: 2) {
            viewModel.refresh()
            self.stubReadUsecase.readItemUpdateMocking.onNext(.removed(itemID: dummyTodo.uid, parent: dummyTodo.parentID))
            self.stubReadUsecase.readItemUpdateMocking.onNext(.removed(itemID: dummyFavoriteID, parent: nil))
            self.stubReadUsecase.readItemUpdateMocking.onNext(.removed(itemID: dummyContinue.uid, parent: dummyContinue.parentID))
        }
        
        // then
        let totalCellLists = sections.map { $0.flatMap { $0.cellViewModels } }
        XCTAssertEqual(totalCellLists.count, 3)
        
        XCTAssertEqual(totalCellLists[safe: 0]?.contains(where: { $0.uid == dummyTodo.uid }), false)
        XCTAssertEqual(totalCellLists[safe: 0]?.contains(where: { $0.uid == dummyFavoriteID }), true)
        XCTAssertEqual(totalCellLists[safe: 0]?.contains(where: { $0.uid == dummyContinue.uid }), true)
        
        XCTAssertEqual(totalCellLists[safe: 1]?.contains(where: { $0.uid == dummyTodo.uid }), false)
        XCTAssertEqual(totalCellLists[safe: 1]?.contains(where: { $0.uid == dummyFavoriteID }), false)
        XCTAssertEqual(totalCellLists[safe: 1]?.contains(where: { $0.uid == dummyContinue.uid }), true)
        
        XCTAssertEqual(totalCellLists[safe: 2]?.contains(where: { $0.uid == dummyTodo.uid }), false)
        XCTAssertEqual(totalCellLists[safe: 2]?.contains(where: { $0.uid == dummyFavoriteID }), false)
        XCTAssertEqual(totalCellLists[safe: 2]?.contains(where: { $0.uid == dummyContinue.uid }), false)
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
    
    class DummyListener: SuggestReadSceneListenable {
        
        func finishSuggesting(_ completed: @escaping () -> Void) {
            completed()
        }
    }
}
