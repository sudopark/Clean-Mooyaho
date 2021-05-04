//
//  SuggestUsecaseTests.swift
//  DomainTests
//
//  Created by ParkHyunsoo on 2021/05/05.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import UnitTestHelpKit

@testable import Domain


class SuggestUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubPlaceRepository: StubPlaceRepository!
    var usecase: SuggestPlaceUsecaseImple!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.stubPlaceRepository = .init()
        self.usecase = SuggestPlaceUsecaseImple(placeRepository: self.stubPlaceRepository)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.stubPlaceRepository = nil
        self.usecase = nil
        super.tearDown()
    }
    
    private var dummyDefaultSuggestResult: SuggestPlaceResult {
        let places = [1, 3, 5].map{ Place.dummy($0) }
        
        return .init(default: places, pageIndex: 0)
    }
    
    private var dummyDetaultPlacesIDs: [String] {
        return self.dummyDefaultSuggestResult.places.map{ $0.uid }
    }
    
    private func dummySuggestResult(range: Range<Int>, pageIndex: Int, query: String) -> SuggestPlaceResult {
        let places = range.map{ Place.dummy($0) }
        return .init(query: query, places: places, pageIndex: pageIndex)
    }
}


extension SuggestUsecaseTests {
    
    private func stubDefaultList(_ result: SuggestPlaceResult? = nil) {
        self.stubPlaceRepository.register(key: "reqeustLoadDefaultPlaceSuggest") {
            return Maybe<SuggestPlaceResult>.just(result ?? self.dummyDefaultSuggestResult)
        }
    }
    
    private func stubSuggestResult(_ query: String, result: SuggestPlaceResult, forPage page: Int? = nil) {
        let key = "requestSuggestPlace:\(query)-\(String(describing: page))"
        self.stubPlaceRepository.register(key: key) {
            return Maybe<SuggestPlaceResult>.just(result)
        }
    }
    
    private func updateSuggestErrorStubbing(_ error: Error?) {
        if let error = error {
            self.stubPlaceRepository.register(type: Error.self, key: "requestSuggestPlace") { error }
        } else {
            self.stubPlaceRepository.register(type: SuggestPlaceResult.self, key: "requestSuggestPlace") { .init(default: []) }
        }
    }
    
    // stat suggest -> show default list
    func testUsecase_whenStartSuggest_showDefaultList() {
        // given
        let expect = expectation(description: "서제스트 시작한 이후에 디폴트 리스트 노출")
        self.stubDefaultList()
        
        // when
        let result = self.waitFirstElement(expect, for: self.usecase.placeSuggestResult, skip: 1) {
            self.usecase.startSuggestPlace(for: .empty, in: .dummy())
        }
        
        // then
        let placeIDs = result?.places.map{ $0.uid }
        XCTAssertEqual(placeIDs, self.dummyDetaultPlacesIDs)
    }
    
    // enter something -> show matching result
    func testUsecase_whenStartSuggestWithParams_showMatchingResult() {
        // given
        let expect = expectation(description: "서제스트시 일치하는 결과 출력")
        expect.expectedFulfillmentCount = 3
        let stubResult = self.dummySuggestResult(range: 0..<10, pageIndex: 1, query: "some")
        self.stubDefaultList()
        self.stubSuggestResult("some", result: stubResult)
        // stub
        
        // when
        let results = self.waitElements(expect, for: self.usecase.placeSuggestResult) {
            self.usecase.startSuggestPlace(for: .empty, in: .dummy())
            self.usecase.startSuggestPlace(for: .some("some"), in: .dummy())
        }
        
        // then
        guard results.count == 3 else {
            XCTFail("기대하는 사이즈가 아님")
            return
        }
        XCTAssertNil(results[0])
        XCTAssertEqual(results[1]?.places.map{ $0.uid }, self.dummyDetaultPlacesIDs)
        XCTAssertEqual(results[2]?.places.map{ $0.uid }, stubResult.places.map{ $0.uid })
    }
    
    // enter something + paging until end
    func testUsecase_whenSuggestAndNextPageExistsAndLoadMore_pagingUntilEnd() {
        // given
        let expect = expectation(description: "서제스트 결과 페이징")
        expect.expectedFulfillmentCount = 3
        let stubResults = (0..<3).map {
            return self.dummySuggestResult(range: $0*10..<$0*10+10, pageIndex: $0, query: "q")
        }
        stubResults.enumerated().forEach { offset, result in
            self.stubSuggestResult(result.query!, result: result, forPage: offset == 0 ? nil : offset)
        }
        
        // when
        let results = self.waitElements(expect, for: self.usecase.placeSuggestResult, skip: 1) {
            self.usecase.startSuggestPlace(for: .some("q"), in: .dummy())
            (0..<10).forEach { _ in
                self.usecase.suggestMore()
                self.usecase.suggestMore()
                self.usecase.suggestMore()
            }
        }
        
        // then
        let placeIDLists = results.map{$0?.placeIDs }
        let expectIDLists = [
            (0..<10).placeIDs,
            (0..<20).placeIDs,
            (0..<30).placeIDs
        ]
        XCTAssertEqual(placeIDLists, expectIDLists)
    }
    
    // enter something + paging -> erase all -> show default list
    func testUsecase_whenSuggesingAndPagingThenEnterEmpty_showDefaultList() {
        // given
        let expect = expectation(description: "서제스트 + 페이징 이후에 서제스트 종료")
        expect.expectedFulfillmentCount = 3
        let pages = [
            self.dummySuggestResult(range: 0..<10, pageIndex: 1, query: "q"),
            self.dummySuggestResult(range: 10..<20, pageIndex: 2, query: "q")
        ]
        self.stubSuggestResult("q", result: pages[0])
        self.stubSuggestResult("q", result: pages[1], forPage: 2)
        self.stubDefaultList()
        
        // when
        let results = self.waitElements(expect, for: self.usecase.placeSuggestResult, skip: 1) {
            self.usecase.startSuggestPlace(for: .some("q"), in: .dummy())
            self.usecase.suggestMore()
            self.usecase.startSuggestPlace(for: .empty, in: .dummy())
        }
        
        // then
        let placeIDLists = results.map{ $0?.placeIDs }
        let expectIDLists = [
            (0..<10).placeIDs,
            (0..<20).placeIDs,
            self.dummyDetaultPlacesIDs
        ]
        XCTAssertEqual(placeIDLists, expectIDLists)
    }
    
    // enter something -> start suggesting -> end entering -> clear
    func testUsecase_whenSSuggesingAndFinishSuggest_clearResult() {
        // given
        let expect = expectation(description: "서제스트 종료 이후에 결과 클리어")
        expect.expectedFulfillmentCount = 3
        let pages = [
            self.dummySuggestResult(range: 0..<10, pageIndex: 1, query: "q"),
            self.dummySuggestResult(range: 10..<20, pageIndex: 2, query: "q")
        ]
        self.stubSuggestResult("q", result: pages[0])
        self.stubSuggestResult("q", result: pages[1], forPage: 2)
        
        // when
        let results = self.waitElements(expect, for: self.usecase.placeSuggestResult, skip: 1) {
            self.usecase.startSuggestPlace(for: .some("q"), in: .dummy())
            self.usecase.suggestMore()
            self.usecase.finishPlaceSuggesting()
        }
        
        // then
        let placeIDLists = results.map{ $0?.placeIDs }
        let expectIDLists = [
            (0..<10).placeIDs,
            (0..<20).placeIDs,
            nil
        ]
        XCTAssertEqual(placeIDLists, expectIDLists)
    }
    
    // enter someting -> error -> change keyword -> continue
    func testUsecase_whenOccurErrorDuringSuggest_ignoreAndKeepSuggesting() {
        // given
        let expect = expectation(description: "서제스트 중 에러 발생해도 무시하고 계속")
        expect.expectedFulfillmentCount = 2
        let pages = [
            self.dummySuggestResult(range: 0..<10, pageIndex: 1, query: "q"),
            self.dummySuggestResult(range: 10..<20, pageIndex: 2, query: "q")
        ]
        self.stubSuggestResult("q", result: pages[0])
        self.stubSuggestResult("q", result: pages[1], forPage: 2)
        
        // when
        let results = self.waitElements(expect, for: self.usecase.placeSuggestResult, skip: 1) {
            self.usecase.startSuggestPlace(for: .some("q"), in: .dummy())
            
            struct DummyError: Error { }
            self.updateSuggestErrorStubbing(DummyError())
            self.usecase.suggestMore()
            
            self.updateSuggestErrorStubbing(nil)
            self.usecase.suggestMore()
        }
        
        // then
        let placeIDLists = results.map{ $0?.placeIDs }
        let expectIDLists = [
            (0..<10).placeIDs,
            (0..<20).placeIDs
        ]
        XCTAssertEqual(placeIDLists, expectIDLists)
    }
    
    func testUsecase_whenReShowDefaultList_useCache() {
        // given
        let expect = expectation(description: "디폴트 리스트를 보여줄때는 캐시를 활용한다")
        expect.expectedFulfillmentCount = 3
        let page = self.dummySuggestResult(range: 0..<10, pageIndex: 1, query: "q")
        self.stubSuggestResult("q", result: page)
        self.stubDefaultList()
        
        // when
        let results = self.waitElements(expect, for: self.usecase.placeSuggestResult, skip: 1) {
            self.usecase.startSuggestPlace(for: .empty, in: .dummy())
            self.usecase.startSuggestPlace(for: .some("q"), in: .dummy())
            
            let newDefault = SuggestPlaceResult(default: [])
            self.stubDefaultList(newDefault)
            self.usecase.startSuggestPlace(for: .empty, in: .dummy())
        }
        
        // then
        let placeIDLists = results.map{ $0?.placeIDs }
        let expectIDLists = [
            self.dummyDetaultPlacesIDs,
            (0..<10).placeIDs,
            self.dummyDetaultPlacesIDs
        ]
        XCTAssertEqual(placeIDLists, expectIDLists)
    }
}


private extension SuggestPlaceResult {
    
    var placeIDs: [String] {
        return self.places.map{ $0.uid }
    }
}

private extension Range where Bound == Int {
    
    var placeIDs: [String] {
        return self.map{ Place.dummy($0) }.map{ $0.uid }
    }
}
