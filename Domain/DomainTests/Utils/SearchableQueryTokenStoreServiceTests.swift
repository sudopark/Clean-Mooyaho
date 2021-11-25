//
//  SearchableQueryTokenStoreServiceTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/11/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import UnitTestHelpKit
import Domain


class SearchableQueryTokenStoreServiceTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var service: SuggestQueryEngine!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.service = SuggestQueryEngineImple()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.service = nil
    }
}


extension SearchableQueryTokenStoreServiceTests {
    
    func testService_suggestQuery() {
        // given
        let expect = expectation(description: "검색어 추천")
        self.service.insertTokens(["test token"])
        self.service.insertTokens(["hello world"])
        self.service.insertTokens(["some world hello "])
        self.service.insertTokens(["hell world"])
        self.service.insertTokens(["mooyaho~"])
        
        // when
        let suggesting = self.service.suggestSearchQuery(by: "hello wor")
        let suggested = self.waitFirstElement(expect, for: suggesting.asObservable())
        
        // then
        XCTAssertEqual(suggested?.count, 3)
        XCTAssertEqual(suggested?.contains("hello world"), true)
        XCTAssertEqual(suggested?.contains("hell world"), true)
        XCTAssertEqual(suggested?.contains("some world hello "), true)
    }
    
    func testService_suggestQuery_orderByNumberOfCountAndMatching() {
        // given
        let expect = expectation(description: "검색어 추천시에 비슷한 정도로 정렬")
        self.service.insertTokens(["검색어 추천 받을 타이틀"])
        self.service.insertTokens(["검색어 추천 받기는 할껀데"])
        self.service.insertTokens(["검갣어 춴"])
        self.service.insertTokens(["검색어 추천 받기는 할꺼야 근에"])
        self.service.insertTokens(["검"])
        
        // when
        let suggesting = self.service.suggestSearchQuery(by: "검색어")
        let suggested = self.waitFirstElement(expect, for: suggesting.asObservable())
        
        // then
        XCTAssertEqual(suggested, [
            "검색어 추천 받을 타이틀",
            "검색어 추천 받기는 할껀데",
            "검갣어 춴"
        ])
    }
    
    func testService_whenMatchingScoreIsSame_prefixMathcingKeywordOrderFirst() {
        // given
        let expect = expectation(description: "검색어 추천시에 입력된 텍스트로 시작된경우에 정렬 우선순위")
        self.service.insertTokens(["검색어 추천"])
        self.service.insertTokens(["추천 검색어"])
        
        // when
        let suggesting = self.service.suggestSearchQuery(by: "검색어")
        let suggested = self.waitFirstElement(expect, for: suggesting.asObservable())
        
        // then
        XCTAssertEqual(suggested, [
            "검색어 추천",
            "추천 검색어"
        ])
    }
    
    func testService_whenAfterClear_nothingSuggest() {
        // given
        let expect = expectation(description: "clear 이후에 검색어 추천시 결과 없음")
        self.service.insertTokens(["검색어 추천"])
        self.service.insertTokens(["추천 검색어"])
        
        // when
        self.service.clearAll()
        let suggesting = self.service.suggestSearchQuery(by: "검색어")
        let suggested = self.waitFirstElement(expect, for: suggesting.asObservable())
        
        // then
        XCTAssertEqual(suggested, [])
    }
}
