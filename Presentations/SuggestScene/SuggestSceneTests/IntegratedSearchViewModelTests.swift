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
        
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.resultMocking = nil
        self.spyRouter = nil
        self.spyListener = nil
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
                ItemCategory(uid: "1", name: "n", colorCode: "c"),
                ItemCategory(uid: "2", name: "n2", colorCode: "c2")
            ]]
        let categoryUsecase = StubItemCategoryUsecase(scenario: scenario)
        
        let routerAndListener = SpyRouterAndListener()
        self.spyRouter = routerAndListener
        self.spyListener = routerAndListener
        
        return IntegratedSearchViewModelImple(searchUsecase: usecase,
                                              categoryUsecase: categoryUsecase,
                                              router: spyRouter,
                                              listener: spyListener)
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
        let expect = expectation(description: "suggest 할때 해당영역 노출")
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
    
    // 검색중 검색중 표시 -> 외부
    func testViewModel_updateIsSearching() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.requestSearchItems(with: "some")
        
        // then
        XCTAssertEqual(self.spyListener.didSearchings, [true, false])
    }
    
    // 검색 완료 이후 서제스트 숨김
    func testViewModel_hideSuggestAfterSearch() {
        // given
        let expect = expectation(description: "검색 완료 이후에 서제스트 영역 숨김")
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
    
    // 검색 실패 이후에 에러 알림
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
    
    // 콜렉션과로 섹션 구성
    func testViewModel_showSearchResultWithSection() {
        // given
        let expect = expectation(description: "검색 결과 섹션 구성하여 노출")
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
    
    // 없는 섹션은 제외
    func testViewModel_whenSearchCollectionIsEmpty_notIncludeCollectionSection() {
        // given
        let expect = expectation(description: "검색결과 없는 아이템(콜렉션)은 제외")
        let viewModel = self.makeViewModel(isEmptyCollections: true)
        
        // when
        let sections = self.waitFirstElement(expect, for: viewModel.searchResultSections) {
            viewModel.requestSearchItems(with: "some")
        }
        
        // then
        XCTAssertEqual(sections?.count, 1)
        XCTAssertEqual(sections?.first?.title, "Links".localized)
    }
    
    // 검색결과에 필요한 카테고리 정보 제공
    func testViewMdoel_showReadItemSearchResultWithCategories() {
        // given
        let expect = expectation(description: "아이템 검색결과 표시시에 카테고리 정보도 같이 노출")
        let viewModel = self.makeViewModel()
        
        // when
        let sections = self.waitFirstElement(expect, for: viewModel.searchResultSections) {
            viewModel.requestSearchItems(with: "some")
        }
        
        // then
        let collectionCell = sections?.first?.cellViewModels.compactMap { $0 as? SearchReadItemCellViewModel }
        XCTAssertEqual(collectionCell?.first?.categories.count, 2)
    }
    
    // 검색중 다시 서제스트 요청 들어온 경우 -> 검색 중지하고 서제스트 결과 노출
    func testViewModel_whenSuggestRequestedDuringSearch_notShowSearchResult() {
        // given
        let expect = expectation(description: "검색 중 서제스트 요청 들어온경우 검색 취소")
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
    
    // 검색결과 선택한경우 스냅샷으로 이동
    func testViewModel_whenSelectReadItemSearchResult_routeToSnapshot() {
        // given
        let expect = expectation(description: "읽기 아이템 검색결과 선택한 경우에는 스냅샷 노출")
        let viewModel = self.makeViewModel()
        
        // when
        let sections = self.waitFirstElement(expect, for: viewModel.searchResultSections) {
            viewModel.requestSearchItems(with: "some")
        }
        let cell = sections?.first?.cellViewModels.randomElement()
        viewModel.showSearchResultDetail(cell?.identifier ?? "")
        
        // then
        XCTAssertEqual(self.spyRouter.didShowSnapshotRequested, true)
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
        
        var didShowSnapshotRequested: Bool?
        func showReadItemSnapshot(_ index: SearchReadItemIndex) {
            self.didShowSnapshotRequested = true
        }
    }
    
    class SpySuggestSceneInteractor: SuggestQuerySceneInteractable {
        
        var didSuggestRequestedText: String?
        func suggest(with text: String) {
            self.didSuggestRequestedText = text
        }
    }
}
