//
//  IntegratedSearchUsecaseTests.swift
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


class IntegratedSearchUsecaseTests: BaseTestCase, WaitObservableEvents {

    var disposeBag: DisposeBag!
    var spySyncUsecase: SpySyncUsecase!

    override func setUpWithError() throws {
        self.disposeBag = .init()
    }

    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spySyncUsecase = nil
    }

    private func makeUsecase(resultIsEmpty: Bool = false) -> IntegratedSearchUsecase {

        let size = resultIsEmpty ? 0 : 10
        let dummies = (0..<size).map { SearchReadItemIndex(itemID: "some:\($0)", displayName: "name:\($0)") }
        let repository = StubSearchRepository()
            |> \.searchResult .~ .success(dummies)
        
        self.spySyncUsecase = .init()

        return IntegratedSearchUsecaseImple(suggestQuerySyncUsecase: self.spySyncUsecase,
                                            searchRepository: repository)
    }
}


extension IntegratedSearchUsecaseTests {

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
    
    func testUsecase_whenAfterSearch_updateSuggestableQueries() {
        // given
        let expect = expectation(description: "검색 이후에 검색가능단어 업데이트")
        let usecase = self.makeUsecase()
        
        // when
        let searching = usecase.search(query: "serched query")
        let result = self.waitFirstElement(expect, for: searching.asObservable())
        
        // then
        let resultDisplayNames = result?.map { $0.displayName } ?? []
        XCTAssertEqual(self.spySyncUsecase.didInsertedQueries, ["serched query"] + resultDisplayNames)
        XCTAssertEqual(self.spySyncUsecase.didInsertedLatestQuery, "serched query")
    }
    
    func testUsecase_whenAfterSearchAndResultIsEmpty_notInsertSearchableQuery() {
        // given
        let expect = expectation(description: "검색결과가 없으면 검색가능한 단어에 추가 안함")
        let usecase = self.makeUsecase(resultIsEmpty: true)
        
        // when
        let searching = usecase.search(query: "serched query")
        let result = self.waitFirstElement(expect, for: searching.asObservable())
        
        // then
        XCTAssertEqual(result?.isEmpty, true)
        XCTAssertEqual(self.spySyncUsecase.didInsertedQueries, nil)
    }
}

extension IntegratedSearchUsecaseTests {
    
    class SpySyncUsecase: SuggestableQuerySyncUsecase {
        
        var didInsertedQueries: [String]?
        func insertSuggestableQueries(_ queries: [String]) {
            self.didInsertedQueries = queries
        }
        
        var didInsertedLatestQuery: String?
        func insertLatestSearchQuery(_ query: String) {
            self.didInsertedLatestQuery = query
        }
    }
}
