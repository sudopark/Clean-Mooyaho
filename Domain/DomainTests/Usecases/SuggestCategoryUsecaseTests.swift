//
//  SuggestCategoryUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/10/09.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import UnitTestHelpKit

import Domain


class SuggestCategoryUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockRepository: StubItemCategoryRepository!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockRepository = nil
    }
    
    private func makeUsecase() -> SuggestCategoryUsecase {
        
        let repository = StubItemCategoryRepository()
        self.mockRepository = repository
    
        return SuggestCategoryUsecaseImple(repository: repository,
                                           throttleInterval: 0)
    }
}

extension SuggestCategoryUsecaseTests {
    
    private func dummyCollection(_ query: String,
                                 page: Int?,
                                 isFianl: Bool = false) -> SuggestCategoryCollection {
        let range = page.map { $0*10..<$0*10+10 } ?? (0..<10)
        let categories = range.map { SuggestCategory(ownerID: nil, category: .dummy($0)) }
        return SuggestCategoryCollection(query: query, currentPage: page,
                                         categories: categories,
                                         isFinalPage: isFianl)
    }
    
    func testUsecase_suggestCategoryItems_withoutPaging() {
        // given
        let expect = expectation(description: "카테고리 서제스트")
        let usecase = self.makeUsecase()
        let page = self.dummyCollection("some", page: nil)
        self.mockRepository.suggestResultMocking = page
        
        // when
        let results = self.waitElements(expect, for: usecase.suggestedCategories.compactMap{ $0 }) {
            usecase.startSuggestCategories(for: nil, query: "some")
            usecase.loadMore()
        }
        
        // then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.categories.count, 10)
    }
    
    func testUsecase_suggestCategoryItems_withPaging() {
        // given
        let expect = expectation(description: "페이징과 함께 카테고리 아이템 서제스트 로드")
        expect.expectedFulfillmentCount = 3
        let usecase = self.makeUsecase()
        let pages = [
            self.dummyCollection("some", page: 0), self.dummyCollection("some", page: 1),
            self.dummyCollection("some", page: 2, isFianl: true)
        ]
        
        // when
        let results = self.waitElements(expect, for: usecase.suggestedCategories.compactMap { $0 }) {
            self.mockRepository.suggestResultMocking = pages.first
            usecase.startSuggestCategories(for: nil, query: "some")
            
            (1..<pages.count).forEach { index in
                self.mockRepository.suggestResultMocking = pages[index]
                usecase.loadMore()
            }
        }
        
        // then
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results.last?.categories.count, 30)
    }
}
