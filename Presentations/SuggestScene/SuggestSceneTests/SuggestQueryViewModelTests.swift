//
//  SuggestQueryViewModelTests.swift
//  SuggestSceneTests
//
//  Created by sudo.park on 2021/11/23.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import Extensions

import UnitTestHelpKit
import UsecaseDoubles

@testable import SuggestScene


class SuggestQueryViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyRouter: SpyRouterAndLister!
    var spyListener: SpyRouterAndLister! {
        self.spyRouter
    }
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyRouter = nil
    }
    
    private func makeViewModel(latests: [String] = [],
                               suggesting: [String] = []) -> SuggestQueryViewModel {
        
        let routerAndListner = SpyRouterAndLister()
        self.spyRouter = routerAndListner
        
        let usecase = StubIntegratedSearchUsecase()
            |> \.latestsQueries .~ latests.map { LatestSearchedQuery(text: $0, time: .now()) }
            |> \.mayBeSearchableQueryMap .~ ["some": suggesting.map { MayBeSearchableQuery(text: $0) }]
        
        return SuggestQueryViewModelImple(suggestQueryUsecase: usecase,
                                          router: routerAndListner,
                                          listener: routerAndListner)
    }
}

extension SuggestQueryViewModelTests {
    
    func testViewModel_showLatestSearchQueries() {
        // given
        let expect = expectation(description: "검색어 없는경우 이전 검색 기록 보여줌")
        let latests = (0..<10).map { "\($0)" }
        let viewModel = self.makeViewModel(latests: latests)
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels, skip: 1) {
            viewModel.suggest(with: "")
        }
        
        // then
        let isAllLatestCell = cvms?.map { $0.isLatestSearched }.count == 10
        let dateText = cvms?.first?.latestSearchText
        XCTAssertEqual(isAllLatestCell, true)
        XCTAssertEqual(dateText, TimeStamp.now().timeAgoText)
    }
    
    func testViewModel_whenEnterSomehting_showMaybeSearchableQueries() {
        // given
        let expect = expectation(description: "검색어 있는경우 검색어 서제스트 보여줌")
        let texts = (0..<10).map { "\($0)" }
        let viewModel = self.makeViewModel(suggesting: texts)
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels, skip: 1) {
            viewModel.suggest(with: "some")
        }
        
        // then
        let isAllMaybeCell = cvms?.map { $0.isLatestSearched == false }.count == 10
        XCTAssertEqual(isAllMaybeCell, true)
    }
    
    func testViewModel_whenResultIsEmpty_showEmptyView() {
        // given
        let expect = expectation(description: "검색어 없는경우 엠티뷰 보여줌")
        expect.expectedFulfillmentCount = 3
        let latests = (0..<10).map { "\($0)" }
        let viewModel = self.makeViewModel(latests: latests, suggesting: [])
        
        // when
        let isEmptys = self.waitElements(expect, for: viewModel.resultIsEmpty) {
            viewModel.suggest(with: "")
            viewModel.suggest(with: "some")
        }
        
        // then
        XCTAssertEqual(isEmptys, [true, false, true])
    }
    
    func testViewModel_whenSelectQurey_requestSearch() {
        // given
        let expect = expectation(description: "서제스트된 검색어 선택하여 검색 요청")
        let latests = (0..<10).map { "\($0)" }
        let viewModel = self.makeViewModel(latests: latests)
        
        // when
        let _ = self.waitElements(expect, for: viewModel.resultIsEmpty, skip: 1) {
            viewModel.suggest(with: "")
            viewModel.selectQuery("3")
        }
        
        // then
        XCTAssertEqual(self.spyListener.didSearchRequested, true)
    }
    
}


extension SuggestQueryViewModelTests {
    
    final class SpyRouterAndLister: SuggestQueryRouting, SuggestQuerySceneListenable, @unchecked Sendable {
        
        var didSearchRequested: Bool?
        func suggestQuery(didSelect searchQuery: String) {
            self.didSearchRequested = true
        }
    }
}
