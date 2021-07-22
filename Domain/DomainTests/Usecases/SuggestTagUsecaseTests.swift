//
//  SuggestTagUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/05/09.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import UnitTestHelpKit

@testable import Domain


class SuggestTagUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockTagRepository: MockTagRepository!
    var usecase: SuggestTagUsecaseImple!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = .init()
        self.mockTagRepository = .init()
        self.usecase = .init(tagRepository: self.mockTagRepository,
                             throttleInterval: 0)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.mockTagRepository = nil
        self.usecase = nil
        super.tearDown()
    }
    
    private func dummyTags(size: Int, offset: Int,
                   type: Tag.TagType) -> [Tag] {
        return (offset*10..<offset*10+size).map {
            .init(type: type, keyword: "k:\($0)")
        }
    }
}


// MARK: - test place comment

extension SuggestTagUsecaseTests {
    
    func testUsecase_whenPlaceCommentQueryIsEmpty_showRecentSearchedKeywords() {
        // given
        let expect = expectation(description: "장소 코멘트 서제스트 키워드가 없는경우 최근 검색했던 태그 노출")
        let type = Tag.TagType.userComments
        self.mockTagRepository.register(type: Maybe<[Tag]>.self, key: "fetchRecentTags:\(type)-") {
            let tags = (0..<10).map{ Tag(type: type, keyword: "k\($0)") }
            return .just(tags)
        }
        
        // when
        let result = self.waitFirstElement(expect, for: self.usecase.suggestTagResults, skip: 1) {
            self.usecase.startSuggestPlaceCommentTag("")
        }
        
        // then
        XCTAssertEqual(result?.tags.count, 10)
    }
    
    func testUsecase_whenCacheExists_queryAndPaging() {
        // given
        let expect = expectation(description: "캐시 존재하는 상태에서 서제스트하고 페이징")
        expect.expectedFulfillmentCount = 3
        let (query, type) = ("k", Tag.TagType.userComments)
        let cached = self.dummyTags(size: 4, offset: 0, type: type)
        let remotePage1 = self.dummyTags(size: 10, offset: 0, type: type)
        let remotePage2 = self.dummyTags(size: 10, offset: 1, type: type)
        
        let results: [SuggestTagResultCollection] = [
            .init(query: query, tags: cached, cursor: nil),
            .init(query: query, tags: remotePage1, cursor: remotePage1.last?.keyword),
            .init(query: query, tags: remotePage2, cursor: nil)
        ]
        
        let keyPage1 = self.mockTagRepository.userCommentStubKey(query: query)
        self.mockTagRepository.register(key: keyPage1) {
            return Observable<SuggestTagResultCollection>.from([results[0], results[1]])
        }
        let keyPage2 = self.mockTagRepository.userCommentStubKey(query: query, cursor: remotePage1.last?.keyword)
        self.mockTagRepository.register(key: keyPage2) {
            return Observable<SuggestTagResultCollection>.just(results[2])
        }
        
        // when
        let collections = self.waitElements(expect, for: self.usecase.suggestTagResults, skip: 1) {
            self.usecase.startSuggestPlaceCommentTag(query)
            self.usecase.loadMoreSuggest()
        }
        
        // then
        XCTAssertEqual(collections.map{ $0?.tags.count }, [4, 10, 20])
    }
    
    func testUsecase_suggestPlaceComment_withPaging() {
        // given
        let expect = expectation(description: "장소 커멘트 타입에 해당하는 키워드 서제스트 + 페이징")
        expect.expectedFulfillmentCount = 3
        let (query, type) = ("k", Tag.TagType.userComments)
        let tagLists: [[Tag]] = (0..<3).map { offset in
            let size = offset == 2 ? 0 : 10
            return self.dummyTags(size: size, offset: offset, type: type)
        }
        tagLists.enumerated().forEach { offset, tags in
            let cursorInResult = tags.last?.keyword
            let cursorForStub = offset == 0 ? nil : tagLists[offset-1].last?.keyword
            
            let result = SuggestTagResultCollection(query: query, tags: tags, cursor: cursorInResult)
            let key = self.mockTagRepository.userCommentStubKey(query: query, cursor: cursorForStub)
            self.mockTagRepository.register(key: key) {
                return Observable<SuggestTagResultCollection>.just(result)
            }
        }
        
        // when
        let collections = self.waitElements(expect, for: self.usecase.suggestTagResults) {
            self.usecase.startSuggestPlaceCommentTag(query) // page1
            self.usecase.loadMoreSuggest()               // page2
            self.usecase.loadMoreSuggest()               // page3 -> empty -> not update
            self.usecase.loadMoreSuggest()               // not load
        }
        
        // then
        XCTAssertEqual(collections.count, 3)
        XCTAssertEqual(collections.map{ $0?.tags.count }, [ nil, 10, 20])
    }
}

extension SuggestTagUsecaseTests {
    
    func testUsecase_queryUserFeelingTag_onlyMine() {
        // given
        let expect = expectation(description: "유저 소유에 해당하는 유저 필링 태그 서제스트")
        let (query, type) = ("k", Tag.TagType.userFeeling)
        let key = "fetchRecentTags:\(type)-\(query)"
        self.mockTagRepository.register(key: key) {
            return Maybe<[Tag]>.just(self.dummyTags(size: 2, offset: 0, type: type))
        }
        
        // when
        let collection = self.waitFirstElement(expect, for: self.usecase.suggestTagResults, skip: 1) {
            self.usecase.stratSuggestUserFeelingTag(query, onlyMine: true)
        }
        
        // then
        XCTAssertEqual(collection?.tags.count, 2)
        XCTAssertEqual(collection?.cursor, nil)
    }
    
    func testUsecase_queryGlobalUserFeelingTag_withPaging() {
        // given
        let expect = expectation(description: "유저 기분 타입에 해당하는 키워드 서제스트 + 페이징")
        expect.expectedFulfillmentCount = 3
        let (query, type) = ("k", Tag.TagType.userFeeling)
        let tagLists: [[Tag]] = (0..<3).map { offset in
            let size = offset == 2 ? 0 : 10
            return self.dummyTags(size: size, offset: offset, type: type)
        }
        tagLists.enumerated().forEach { offset, tags in
            let cursorInResult = tags.last?.keyword
            let cursorForStub = offset == 0 ? nil : tagLists[offset-1].last?.keyword

            let result = SuggestTagResultCollection(query: query, tags: tags, cursor: cursorInResult)
            let key = self.mockTagRepository.userFeelingStubKey(query: query, cursor: cursorForStub)
            self.mockTagRepository.register(key: key) {
                return Observable<SuggestTagResultCollection>.just(result)
            }
        }

        // when
        let collections = self.waitElements(expect, for: self.usecase.suggestTagResults) {
            self.usecase.stratSuggestUserFeelingTag(query, onlyMine: false)
            self.usecase.loadMoreSuggest()               // page2
            self.usecase.loadMoreSuggest()               // page3 -> empty -> not update
            self.usecase.loadMoreSuggest()               // not load
        }

        // then
        XCTAssertEqual(collections.count, 3)
        XCTAssertEqual(collections.map{ $0?.tags.count }, [ nil, 10, 20])
    }
}
