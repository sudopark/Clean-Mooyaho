//
//  SuggestQueryUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/11/26.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import UnitTestHelpKit
import Domain


class SuggestQueryUsecaseTests: BaseTestCase, WaitObservableEvents {
 
    var disposeBag: DisposeBag!
    var spySuggestEngine: StubSuggestQueryEngine!
    var spyRepository: StubSearchRepository!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spySuggestEngine = nil
        self.spyRepository = nil
    }
    
    private func makeUsecase(latestQueries: [String] = [],
                             searchables: [String] = []) -> SuggestQueryUsecaseImple {

        let engine = StubSuggestQueryEngine()
        self.spySuggestEngine = engine

        let queries = latestQueries.map { LatestSearchedQuery(text: $0, time: .now()) }

//        let dummies = (0..<10).map { SearchReadItemIndex(itemID: "some:\($0)", displayName: "name:\($0)") }
        let repository = StubSearchRepository()
            |> \.suggestableQueries .~ searchables
            |> \.lastestQueries .~ queries
        self.spyRepository = repository

        return SuggestQueryUsecaseImple(suggestQueryEngine: engine, searchRepository: repository)
    }
}

extension SuggestQueryUsecaseTests {
    
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


extension SuggestQueryUsecaseTests {
    
    // 검색가능 단어 추가하고난 이후에 서제스트 돌림
    func testUSecase_insertSuggestableQueries() {
        // given
        let expect = expectation(description: "서제스트가능 단어 추가하고 서제스트")
        expect.expectedFulfillmentCount = 2
        let oldQuries = ["old"]
        let usecase = self.makeUsecase(searchables: oldQuries)
        
        // when
        let queryLists = self.waitElements(expect, for: usecase.suggestingQuery) {
            usecase.startSuggest(query: "some")
            usecase.insertSuggestableQueries(["new1", "new2"])
            usecase.startSuggest(query: "some")
        }
        
        // then
        let (result1, result2) = (queryLists.first, queryLists.last)
        XCTAssertEqual(result1?.map { $0.text }, ["old"])
        XCTAssertEqual(result2?.map { $0.text }, ["old", "new1", "new2"])
        XCTAssertEqual(self.spyRepository.didInsertedSuggestableQueris, ["new1", "new2"])
    }
    
    // 마지막 검색어 삭제 이후에 마지막 검색 노출
    func testUsecase_removeLatestSearchQuery() {
        // given
        let expect = expectation(description: "검색어 기록 삭제")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase(latestQueries: ["1", "target", "2"])

        // when
        let queryLists = self.waitElements(expect, for: usecase.suggestingQuery) {
            usecase.startSuggest(query: "")
            usecase.removeSearchedQuery("target")
        }

        // then
        XCTAssertEqual(queryLists.map { $0.map { $0.text } }, [
            ["1", "target", "2"],
            ["1", "2"]
        ])
    }
}


extension SuggestQueryUsecaseTests {
    
    class StubSuggestQueryEngine: SuggestQueryEngine {

        var didInsetedTokens: [String]?
        func insertTokens(_ texts: [String]) {
            self.didInsetedTokens = texts
            self.queries += texts
        }

        func removeToken(_ text: String) {
            self.queries = self.queries.filter { $0 != text }
        }

        private var queries = [String]()
        func suggestSearchQuery(by keyword: String) -> Maybe<[String]> {
            return .just(self.queries)
        }

        func clearAll() { }
    }
}
