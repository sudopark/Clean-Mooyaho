//
//  RepositoryTests+Tag.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/05/10.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

@testable import DataStore


class RepositoryTests_Tag: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubRemote: StubRemote!
    var stubLocal: StubLocal!
    var repository: DummyRepository!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = .init()
        self.stubLocal = .init()
        self.stubRemote = .init()
        self.repository = .init(remote: self.stubRemote, local: self.stubLocal)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.stubRemote = nil
        self.stubLocal = nil
        self.repository = nil
        super.tearDown()
    }
}

extension RepositoryTests_Tag {
    
    func testRepository_fetchRecentTags() {
        // given
        let expect = expectation(description: "로컬에 저장된 최근 태그 로드")
        self.stubLocal.register(key: "fetchRecentSelectTags") {
            return Maybe<[Tag]>.just([Tag.init(type: .userComments, keyword: "some")])
        }
        
        // when
        let tags = self.waitFirstElement(expect, for: self.repository.fetchRecentPlaceCommentTag().asObservable()) { }
        
        // then
        XCTAssertEqual(tags?.count, 1)
    }
    
    // 삭제 이후에 최근 검색에서 삭제
    func testRepository_removeRecentTag() {
        // given
        let expect = expectation(description: "로컬에 저장된 최근 태그 삭제")
        self.stubLocal.register(key: "removeRecentSelect") {
            return Maybe<Void>.just()
        }
        
        // when
        let tag = Tag(type: .userComments, keyword: "some")
        let void: Void? = self.waitFirstElement(expect, for: self.repository.removeRecentSelect(tag: tag).asObservable()) { }
        
        // then
        XCTAssertNotNil(void)
    }
    
    func testRepository_makeNewTag() {
        // given
        let expect = expectation(description: "태그 생성시에 업로드 + 최근 선택한 테그 업데이트")
        expect.expectedFulfillmentCount = 2
        self.stubRemote.register(key: "requestRegisterTag") { Maybe<Void>.just() }
        self.stubLocal.register(key: "updateRecentSelect") { Maybe<Void>.just() }
        
        self.stubLocal.called(key: "updateRecentSelect") { _ in
            expect.fulfill()
        }
        
        // when
        let tag = Tag(type: .userComments, keyword: "some")
        let void: Void? = self.waitFirstElement(expect, for: self.repository.makeNew(tag: tag).asObservable()) { }
        
        // then
        XCTAssertNotNil(void)
    }
    
    func testRepository_selectTag() {
        // given
        let expect = expectation(description: "태그 선택시에 최근 선택한 테그 업데이트")
        self.stubLocal.register(key: "updateRecentSelect") { Maybe<Void>.just() }
        
        
        // when
        let tag = Tag(type: .userComments, keyword: "some")
        let void: Void? = self.waitFirstElement(expect, for: self.repository.select(tag: tag).asObservable()) { }
        
        // then
        XCTAssertNotNil(void)
    }
    
    // 커서 없으면 유저 커멘트 캐시랑 같이 방출
    func testRepository_whenLoadUserCommentTagsWithoutCursor_hitCache() {
        // given
        let expect = expectation(description: "유저 커멘트 커서 없을때는 캐시 히트해서 불러옴")
        expect.expectedFulfillmentCount = 2
        self.stubLocal.register(key: "fetchRecentSelectTags") {
            return Maybe<[Tag]>.just([Tag.init(type: .userComments, keyword: "cache")])
        }
        self.stubRemote.register(key: "requestLoadPlaceCommnetTags") {
            return Maybe<SuggestTagResultCollection>.just(.init(query: "k", tags: [.init(type: .userComments, keyword: "remote")], cursor: nil))
        }
        
        // when
        let tagLists = self.waitElements(expect, for: self.repository.requestLoadPlaceCommnetTags("k", cursor: nil)) { }
        
        // then
        XCTAssertEqual(tagLists.map{ $0.tags.first?.keyword }, ["cache", "remote"] )
    }
    
    func testRepository_whenLoadUserComment_cachingLoadResult() {
        // given
        let expect = expectation(description: "유저 커멘트 커서는 조회시에 캐싱됨")
        
        self.stubLocal.called(key: "saveTags") { _ in
            expect.fulfill()
        }
        self.stubRemote.register(key: "requestLoadPlaceCommnetTags") {
            return Maybe<SuggestTagResultCollection>.just(.init(query: "k", tags: [.init(type: .userComments, keyword: "remote")], cursor: nil))
        }
        
        // when
        self.repository.requestLoadPlaceCommnetTags("some", cursor: "cur")
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    // 커서 있으면 캐시 없이 방출
    func testRepository_loadUserCommentTagsWithCursor() {
        // given
        let expect = expectation(description: "유저 커멘트 커서 있는경우 로드")
        self.stubRemote.register(key: "requestLoadPlaceCommnetTags") {
            return Maybe<SuggestTagResultCollection>.just(.init(query: "k", tags: [.init(type: .userComments, keyword: "remote")], cursor: nil))
        }
        
        // when
        let tagLists = self.waitElements(expect, for: self.repository.requestLoadPlaceCommnetTags("k", cursor: nil)) { }
        
        // then
        XCTAssertEqual(tagLists.count, 1)
    }
    
    // 커서 없으면 기분 캐시랑 같이 방출
    func testRepository_whenLoadUserFeelingTagsWithoutCursor_hitCache() {
        // given
        let expect = expectation(description: "유저 기분 커서 없을때는 캐시 히트해서 불러옴")
        expect.expectedFulfillmentCount = 2
        self.stubLocal.register(key: "fetchRecentSelectTags") {
            return Maybe<[Tag]>.just([Tag.init(type: .userFeeling, keyword: "cache")])
        }
        self.stubRemote.register(key: "requestLoadUserFeelingTags") {
            return Maybe<SuggestTagResultCollection>.just(.init(query: "k", tags: [.init(type: .userFeeling, keyword: "remote")], cursor: nil))
        }
        
        // when
        let tagLists = self.waitElements(expect, for: self.repository.requestLoadUserFeelingTags("k", cursor: nil)) { }
        
        // then
        XCTAssertEqual(tagLists.map{ $0.tags.first?.keyword }, ["cache", "remote"] )
    }
    
    // 커서 있으면 캐시 없이 방출
    func testRepository_loadUserFeelingTagsWithCursor() {
        // given
        let expect = expectation(description: "유저 기분 커서 있는경우 로드")
        self.stubRemote.register(key: "requestLoadUserFeelingTags") {
            return Maybe<SuggestTagResultCollection>.just(.init(query: "k", tags: [.init(type: .userFeeling, keyword: "remote")], cursor: nil))
        }
        
        // when
        let tagLists = self.waitElements(expect, for: self.repository.requestLoadUserFeelingTags("k", cursor: nil)) { }
        
        // then
        XCTAssertEqual(tagLists.count, 1)
    }
}


extension RepositoryTests_Tag {
    
    class DummyRepository: TagRespository, TagRepositoryDefImpleDependency {
        let remote: TagRemote
        let local: TagLocalStorage
        let disposeBag: DisposeBag = .init()
        
        init(remote: TagRemote, local: TagLocalStorage) {
            self.remote = remote
            self.local = local
        }
    }
}
