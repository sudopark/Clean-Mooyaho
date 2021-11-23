//
//  SuggestReadItemUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/11/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import UnitTestHelpKit
import Domain


class SuggestReadItemUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spySuggestQueryService: StubSearchQueryStoreService!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spySuggestQueryService = nil
    }
    
    private func makeUsecase(latestQueries: [String] = [],
                             searchables: [String] = [],
                             shouldFailSearch: Bool = false) -> SuggestReadItemUsecaseImple {
        
        let service = StubSearchQueryStoreService()
            |> \.queries .~ searchables
        
        self.spySuggestQueryService = service
        
        let queries = latestQueries.map { LatestSearchedQuery(text: $0, time: .now()) }
        
        let dummies = (0..<10).map { SearchReadItemIndex(itemID: "some:\($0)", displayName: "name:\($0)") }
        let repository = StubSearchRepository()
            |> \.lastestQueries .~ queries
            |> \.searchResult .~ (shouldFailSearch ? .failure(ApplicationErrors.invalid) : .success(dummies))
        
        return SuggestReadItemUsecaseImple(searchQueryStoraService: service,
                                           searchRepository: repository)
    }
}

extension SuggestReadItemUsecaseTests {
    
    func testUsecase_whenStartQueryWithEmptyQuery_showLatestSearchQueries() {
        // given
        let expect = expectation(description: "검색어 비어있을경우에는 이전에 검색한 기록 노출")
        let usecase = self.makeUsecase(latestQueries: ["1", "2"])
        
        // when
        let queries = self.waitFirstElement(expect, for: usecase.suggestingQuery) {
            usecase.startSuggest(query: "")
        }
        
        // then
        XCTAssertEqual(queries.map { $0.map { $0.text } }, ["1", "2"])
    }
    
    func testUsecase_whenQueryIsNotEmpty_showSearchableQueries() {
        // given
        let expect = expectation(description: "검색어 압력한 경우에는 검색가능한 단어 추천")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase(latestQueries: ["1", "2"], searchables: ["119", "112"])
        
        // when
        let queryLists = self.waitElements(expect, for: usecase.suggestingQuery) {
            usecase.startSuggest(query: "")
            usecase.startSuggest(query: "1")
        }
        
        // then
        XCTAssertEqual(queryLists.map { $0.map { $0.text } }, [
            ["1", "2"],
            ["119", "112"]
        ])
    }
}

extension SuggestReadItemUsecaseTests {
    
    func testUsecase_search() {
        // given
        let expect = expectation(description: "검색")
        let usecase = self.makeUsecase()
        
        // when
        let searching = usecase.search(query: "some")
        let result = self.waitFirstElement(expect, for: searching.asObservable())
        
        // then
        XCTAssertEqual(result?.isNotEmpty, true)
    }
    
    func testUsecase_whenAfterSearch_showAtLatestQueryList() {
        // given
        let expect = expectation(description: "검색한 이후에 최근 검색한 목록에 노출")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase(latestQueries: ["one", "two"])
        
        // when
        let queryLists = self.waitElements(expect, for: usecase.suggestingQuery) {
            usecase.startSuggest(query: "")
            usecase.search(query: "new")
                .subscribe(onSuccess: { _ in
                    usecase.startSuggest(query: "")
                })
                .disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertEqual(queryLists.map { $0.map { $0.text } }, [
            ["one", "two"],
            ["new", "one", "two"]
        ])
    }
    
    func testUsecase_whenAfterSearch_updateSearchableQueries() {
        // given
        let expect = expectation(description: "검색 이후에 해당 검색어 검색어 추천에 노출")
        let usecase = self.makeUsecase()
        
        // when
        let searching = usecase.search(query: "some")
        let _ = self.waitFirstElement(expect, for: searching.asObservable())
        
        // then
        XCTAssertEqual(self.spySuggestQueryService.didInsetedToken, "some")
    }
    
    func testUsecase_removeLatestSearchQuery() {
        // given
        let expect = expectation(description: "검색어 기록 삭제")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase(latestQueries: ["1", "target", "2"])
        
        // when
        let queryLists = self.waitElements(expect, for: usecase.suggestingQuery) {
            usecase.startSuggest(query: "")
            usecase.removeLatestSearchedQuery("target")
        }
        
        // then
        XCTAssertEqual(queryLists.map { $0.map { $0.text } }, [
            ["1", "target", "2"],
            ["1", "2"]
        ])
    }
}


extension SuggestReadItemUsecaseTests {
    
    class StubSearchQueryStoreService: SearchableQueryTokenStoreService {
        
        var didInsetedToken: String?
        func insertTokens(_ text: String) {
            self.didInsetedToken = text
        }
        
        func removeToken(_ text: String) {
            self.queries = self.queries.filter { $0 != text }
        }
        
        var queries = [String]()
        func suggestSearchQuery(by keyword: String) -> Maybe<[String]> {
            return .just(self.queries)
        }
        
        func clearAll() { }
    }
    
    class StubSearchRepository: IntegratedSearchReposiotry {
        
        var searchResult: Result<[SearchReadItemIndex], Error> = .success([])
        func requestSearchReadItem(by keyword: String) -> Maybe<[SearchReadItemIndex]> {
            return searchResult.asMaybe()
        }
        
        var lastestQueries: [LatestSearchedQuery] = []
        func fetchLatestSearchQueries() -> Maybe<[LatestSearchedQuery]> {
            return .just(self.lastestQueries)
        }
        
        func removeLatestSearchQuery(_ query: String) -> Maybe<Void> {
            return .just()
        }
    }
}

