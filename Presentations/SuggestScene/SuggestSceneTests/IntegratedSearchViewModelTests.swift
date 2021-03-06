//
//  IntegratedSearchViewModelTests.swift
//  SuggestSceneTests
//
//  Created by sudo.park on 2021/11/24.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

import SuggestScene


class IntegratedSearchViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyRouter: SpyRouterAndListener!
    var spyListener: SpyRouterAndListener!
    var resultMocking: PublishSubject<[SearchReadItemIndex]>?
    var spyReadcollectionInteractor: SpyReadCollectionMainInteractor!
        
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.resultMocking = nil
        self.spyRouter = nil
        self.spyListener = nil
        self.spyReadcollectionInteractor = nil
    }
    
    private var dummyCollectionIndexes: [SearchReadItemIndex] {
        return (0..<10).map {
            return SearchReadItemIndex(itemID: "c:\($0)", isCollection: true, displayName: "n:\($0)")
                |> \.categoryIDs .~ ["1", "2"]
        }
    }
    
    private var dummyLinkIndexes: [SearchReadItemIndex] {
        return (0..<10).map {
            return SearchReadItemIndex(itemID: "l:\($0)", isCollection: false, displayName: "n:\($0)")
        }
    }
    
    private func makeViewModel(shouldFailSearch: Bool = false,
                               isEmptyLinks: Bool = false,
                               isEmptyCollections: Bool = false) -> IntegratedSearchViewModel {
        
        let dummyIndexes = (isEmptyLinks ? [] : self.dummyLinkIndexes)
            + (isEmptyCollections ? [] : self.dummyCollectionIndexes)
        
        let usecase = StubIntegratedSearchUsecase()
            |> \.searchReadItemResult .~ (shouldFailSearch ? .failure(ApplicationErrors.invalid) : .success(dummyIndexes))
            |> \.searchResultMocking .~ self.resultMocking
        
        let scenario = StubItemCategoryUsecase.Scenario()
            |> \.categories .~ [[
                ItemCategory(uid: "1", name: "n", colorCode: "c", createdAt: .now()),
                ItemCategory(uid: "2", name: "n2", colorCode: "c2", createdAt: .now())
            ]]
        let categoryUsecase = StubItemCategoryUsecase(scenario: scenario)
        
        let routerAndListener = SpyRouterAndListener()
        self.spyRouter = routerAndListener
        self.spyListener = routerAndListener
        
        self.spyReadcollectionInteractor = .init()
        
        return IntegratedSearchViewModelImple(searchUsecase: usecase,
                                              categoryUsecase: categoryUsecase,
                                              router: spyRouter,
                                              listener: spyListener,
                                              readCollectionMainInteractor: self.spyReadcollectionInteractor)
    }
}


// MARK: - seutp suggest + start

extension IntegratedSearchViewModelTests {
    
    func testViewModel_setupSuggestScene() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.setupSubScene()
        
        // then
        XCTAssertEqual(self.spyRouter.didSetupSuggestScene, true)
    }
    
    func testViewModel_whenSetupSuggest_startSuggestWithEmptyQuery() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.setupSubScene()
        
        // then
        XCTAssertEqual(self.spyRouter.spySuggestSceneInteractor?.didSuggestRequestedText, "")
    }
    
    func testViewModel_whenSuggestSomething_showSuggestScene() {
        // given
        let expect = expectation(description: "suggest ?????? ???????????? ??????")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel()
        
        // when
        let isShowing = self.waitElements(expect, for: viewModel.showSuggestScene) {
            viewModel.setupSubScene()
            viewModel.requestSuggest(with: "")
        }
        
        // then
        XCTAssertEqual(isShowing, [false, true])
    }
}

// MARK: - request search

extension IntegratedSearchViewModelTests {
    
    // ????????? ????????? ?????? -> ??????
    func testViewModel_updateIsSearching() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.requestSearchItems(with: "some")
        
        // then
        XCTAssertEqual(self.spyListener.didSearchings, [true, false])
    }
    
    // ?????? ?????? ?????? ???????????? ??????
    func testViewModel_hideSuggestAfterSearch() {
        // given
        let expect = expectation(description: "?????? ?????? ????????? ???????????? ?????? ??????")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel()
        
        // when
        let isShowings = self.waitElements(expect, for: viewModel.showSuggestScene) {
            viewModel.setupSubScene()
            viewModel.requestSuggest(with: "some")
            viewModel.requestSearchItems(with: "some")
        }
        
        // then
        XCTAssertEqual(isShowings, [false, true, false])
    }
    
    // ?????? ?????? ????????? ?????? ??????
    func testViewModel_whenSearchFail_showError() {
        // given
        let viewModel = self.makeViewModel(shouldFailSearch: true)
        
        // when
        viewModel.requestSearchItems(with: "some")
        
        // then
        XCTAssertEqual(self.spyRouter.didAlertError, true)
    }
}

// MARK: - searched cellviewModels

extension IntegratedSearchViewModelTests {
    
    // ??????????????? ?????? ??????
    func testViewModel_showSearchResultWithSection() {
        // given
        let expect = expectation(description: "?????? ?????? ?????? ???????????? ??????")
        let viewModel = self.makeViewModel()
        
        // when
        let sections = self.waitFirstElement(expect, for: viewModel.searchResultSections) {
            viewModel.requestSearchItems(with: "some")
        }
        
        // then
        XCTAssertEqual(sections?.count, 2)
        XCTAssertEqual(sections?.first?.title, "Collections".localized)
        XCTAssertEqual(sections?.last?.title, "Links".localized)
    }
    
    // ?????? ????????? ??????
    func testViewModel_whenSearchCollectionIsEmpty_notIncludeCollectionSection() {
        // given
        let expect = expectation(description: "???????????? ?????? ?????????(?????????)??? ??????")
        let viewModel = self.makeViewModel(isEmptyCollections: true)
        
        // when
        let sections = self.waitFirstElement(expect, for: viewModel.searchResultSections) {
            viewModel.requestSearchItems(with: "some")
        }
        
        // then
        XCTAssertEqual(sections?.count, 1)
        XCTAssertEqual(sections?.first?.title, "Links".localized)
    }
    
    // ??????????????? ????????? ???????????? ?????? ??????
    func testViewMdoel_showReadItemSearchResultWithCategories() {
        // given
        let expect = expectation(description: "????????? ???????????? ???????????? ???????????? ????????? ?????? ??????")
        let viewModel = self.makeViewModel()
        
        // when
        let sections = self.waitFirstElement(expect, for: viewModel.searchResultSections) {
            viewModel.requestSearchItems(with: "some")
        }
        
        // then
        let collectionCell = sections?.first?.cellViewModels.compactMap { $0 as? SearchReadItemCellViewModel }
        XCTAssertEqual(collectionCell?.first?.categories.count, 2)
    }
    
    // ????????? ?????? ???????????? ?????? ????????? ?????? -> ?????? ???????????? ???????????? ?????? ??????
    func testViewModel_whenSuggestRequestedDuringSearch_notShowSearchResult() {
        // given
        let expect = expectation(description: "?????? ??? ???????????? ?????? ??????????????? ?????? ??????")
        expect.isInverted = true
        self.resultMocking = .init()
        let viewModel = self.makeViewModel()
        
        // when
        let result = self.waitFirstElement(expect, for: viewModel.searchResultSections) {
            viewModel.setupSubScene()
            viewModel.requestSearchItems(with: "some")
            viewModel.requestSuggest(with: "some")
            self.resultMocking?.onNext(self.dummyCollectionIndexes)
        }
        
        // then
        XCTAssertNil(result)
    }
}

// MARK: - route search result

extension IntegratedSearchViewModelTests {
    
    func testViewModel_whenSelectReadLinkSearchResult_routeToSnapshot() {
        // given
        let expect = expectation(description: "?????? ????????? ???????????? ????????? ???????????? ???????????? ??????")
        let viewModel = self.makeViewModel()
        
        // when
        let sections = self.waitFirstElement(expect, for: viewModel.searchResultSections) {
            viewModel.requestSearchItems(with: "some")
        }
        let cell = sections?.last?.cellViewModels.first
        viewModel.showSearchResultDetail(cell?.identifier ?? "")
        
        // then
        XCTAssertEqual(self.spyRouter.didShowLinkDetail, true)
    }
    
    func testViewModel_whenSelectCollectionSearchResult_finishSearchAndJumpToColleciton() {
        // given
        let expect = expectation(description: "??????????????? ????????? ????????? ???????????? ?????? ???????????? ????????? ???????????? ???????????? ??????")
        let viewModel = self.makeViewModel()
        
        // when
        let sections = self.waitFirstElement(expect, for: viewModel.searchResultSections) {
            viewModel.requestSearchItems(with: "some")
        }
        let cell = sections?.first?.cellViewModels.first
        viewModel.showSearchResultDetail(cell?.identifier ?? "")
        
        // then
        XCTAssertEqual(self.spyListener.didFinishSearch, true)
        XCTAssertEqual(self.spyReadcollectionInteractor.didJumpRequested, true)
    }
}


extension IntegratedSearchViewModelTests {
    
    class SpyRouterAndListener: IntegratedSearchRouting, IntegratedSearchSceneListenable {
        
        var spySuggestSceneInteractor: SpySuggestSceneInteractor?
        var didSetupSuggestScene: Bool?
        func setupSuggestScene() -> SuggestQuerySceneInteractable? {
            self.didSetupSuggestScene = true
            self.spySuggestSceneInteractor = .init()
            return self.spySuggestSceneInteractor
        }
        
        
        var didSearchings: [Bool] = []
        func integratedSearch(didUpdateSearching: Bool) {
            self.didSearchings.append(didUpdateSearching)
        }
        
        var didAlertError: Bool?
        func alertError(_ error: Error) {
            self.didAlertError = true
        }
        
        var didShowLinkDetail: Bool?
        func showLinkDetail(_ linkID: String) {
            self.didShowLinkDetail = true
        }
        
        var didFinishSearch: Bool?
        func finishIntegratedSearch(_ completed: @escaping () -> Void) {
            self.didFinishSearch = true
            completed()
        }
    }
    
    class SpySuggestSceneInteractor: SuggestQuerySceneInteractable {
        
        var didSuggestRequestedText: String?
        func suggest(with text: String) {
            self.didSuggestRequestedText = text
        }
    }
    
    class SpyReadCollectionMainInteractor: ReadCollectionMainSceneInteractable {
        
        func addNewCollectionItem() { }
        
        func addNewReadLinkItem() { }
        
        func addNewReaedLinkItem(with url: String) { }
        
        func switchToSharedCollection(_ collection: SharedReadCollection) { }
        
        func switchToMyReadCollections() { }
        
        var didJumpRequested: Bool?
        func jumpToCollection(_ collectionID: String?) {
            self.didJumpRequested = true
        }
        
        var rootType: CollectionRoot = .myCollections
    }
}
