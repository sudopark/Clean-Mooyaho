//
//  SearchNewPlaceUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/05/08.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import UnitTestHelpKit

@testable import Domain


class SearchNewPlaceUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubPlaceRepository: StubPlaceRepository!
    var usecase: SearchNewPlaceUsecaseImple!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = .init()
        self.stubPlaceRepository = .init()
        self.usecase = SearchNewPlaceUsecaseImple(placeRepository: self.stubPlaceRepository)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.stubPlaceRepository = nil
        self.usecase = nil
        super.tearDown()
    }
    
    private func dummyResult(page: Int, isFinalPage: Bool, query: String) -> SearchingPlaceCollection {
        let size = isFinalPage ? 0 : 10
        let range = page*10..<page*10+size
        let places = range.map{ SearchingPlace.dummy($0) }
        return .init(query: query, currentPage: page, places: places)
    }
    
    private func dummyResults(for query: String, size: Int) -> [SearchingPlaceCollection] {
        return (0..<size).map { index in
            return self.dummyResult(page: index, isFinalPage: index==size-1, query: query)
        }
    }
    
    func stubResult(_ result: SearchingPlaceCollection, for query: String, of page: Int? = nil) {
        let key = "requestSearchNewPlace:\(query)-\(String(describing: page))"
        self.stubPlaceRepository.register(key: key) {
            return Maybe<SearchingPlaceCollection>.just(result)
        }
    }
}


extension SearchNewPlaceUsecaseTests {
    
    func testUsecase_searchNewPlace() {
        // given
        let expect = expectation(description: "새로운 장소 탐색")
        expect.expectedFulfillmentCount =  2 + 1 + 1
        let q1Results = self.dummyResults(for: "q1", size: 3)
        let q2Results = self.dummyResults(for: "q2", size: 2)
        q1Results.enumerated().forEach { offset, result in
            self.stubResult(result, for: "q1", of: offset == 0 ? nil : offset)
        }
        q2Results.enumerated().forEach { offset, result in
            self.stubResult(result, for: "q2", of: offset == 0 ? nil : offset)
        }
        
        // when
        let collections = self.waitElements(expect, for: self.usecase.newPlaceSearchResult, skip: 1) {
            self.usecase.startSearchPlace(for: .empty, in: .dummy()) // ignore
            
            let p1 = SuggestPlaceQuery.some("q1")
            self.usecase.startSearchPlace(for: p1, in: .dummy())
            self.usecase.loadMorePlaceSearchResult()
            self.usecase.loadMorePlaceSearchResult()    // 마지막 페이지 걸려점
            self.usecase.loadMorePlaceSearchResult()    // over request
            
            let p2 = SuggestPlaceQuery.some("q2")
            self.usecase.startSearchPlace(for: p2, in: .dummy())
            self.usecase.loadMorePlaceSearchResult()    // 마지막 페이지 걸러짐
            self.usecase.loadMorePlaceSearchResult()    // over request
            
            self.usecase.finishSearchPlace()            // 초기화
        }
        
        // then
        let queries = collections.map{ $0?.query }
        let placeIDLists = collections.map{ $0?.placeIDs }
        XCTAssertEqual(queries, ["q1", "q1", "q2", nil])
        XCTAssertEqual(placeIDLists, [
            (0..<10).placeIDs,
            (0..<20).placeIDs,
            (0..<10).placeIDs,
            nil
        ])
    }
}


private extension SearchingPlaceCollection {
    
    var placeIDs: [String] {
        return self.places.map{ $0.uid }
    }
}

private extension Range where Bound == Int {
    
    var placeIDs: [String] {
        return self.map{ Place.dummy($0) }.map{ $0.uid }
    }
}
