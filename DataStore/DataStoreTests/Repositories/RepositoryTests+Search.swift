//
//  RepositoryTests+Search.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/11/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import UnitTestHelpKit

import DataStore


class RepositoryTests_Search: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockRemote: MockRemote!
    var mockLocal: MockLocal!
    var repository: DummyRepository!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockRemote = .init()
        self.mockLocal = .init()
        self.repository = .init(local: self.mockLocal, remote: self.mockRemote)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockRemote = nil
        self.mockLocal = nil
        self.repository = nil
    }
}


// MARK: - search

extension RepositoryTests_Search {
    
    func testRepository_suggestReadItem_withoutSignIn() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 리드아이템 서제스트")
        self.mockLocal.register(key: "suggestReadItems") {
            Maybe<[SearchReadItemIndex]>.just([SearchReadItemIndex(itemID: "some", displayName: "name")])
        }
        
        // when
        let suggesting = self.repository.requestSearchReadItem(by: "some")
        let indexes = self.waitFirstElement(expect, for: suggesting.asObservable())
        
        // then
        XCTAssertEqual(indexes?.count, 1)
    }
    
    func testRepository_suggestReadItem_withSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 리드아이템 서제스트")
        self.mockRemote.register(key: "requestSuggestItem") {
            Maybe<[SearchReadItemIndex]>.just([SearchReadItemIndex(itemID: "some", displayName: "name")])
        }
        
        // when
        let suggesting = self.repository.requestSearchReadItem(by: "some")
        let indexes = self.waitFirstElement(expect, for: suggesting.asObservable())
        
        // then
        XCTAssertEqual(indexes?.count, 1)
    }
}


// MARK: - latest query

extension RepositoryTests_Search {
    
    func testRepository_fetchLatestSearchQueries() {
        // given
        let expect = expectation(description: "최근 검색한 쿼리 목록 로드")
        self.mockLocal.register(key: "fetchLatestSearchedQueries") {
            return Maybe<[LatestSearchedQuery]>.just([.init(text: "some", time: .now())])
        }
        
        // when
        let fetching = repository.fetchLatestSearchQueries()
        let queries = self.waitFirstElement(expect, for: fetching.asObservable())
        
        // then
        XCTAssertEqual(queries?.isNotEmpty, true)
    }
    
    func testReposiotry_whenAfterSearch_updateInsertToLatestSearchKeywordList() {
        // given
        let expect = expectation(description: "검색 이후에 최근에 사용한 검색어 목록에 추가")
        self.mockRemote.register(key: "requestSuggestItem") {
            Maybe<[SearchReadItemIndex]>.just([SearchReadItemIndex(itemID: "some", displayName: "name")])
        }
        
        self.mockLocal.called(key: "insertLatestSearchQuery") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository.requestSearchReadItem(by: "some")
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testRepository_downloadSuggestableQueries() {
        // given
        let expect = expectation(description: "검색가능한 리드아이템 단어 다운로드")
        self.mockRemote.register(key: "requestLoadAllSearchableReadItemTexts") { Maybe<[String]>.just(["some"]) }
        
        // when
        let loading = self.repository.downloadAllSuggestableQueries(memberID: "some")
        let result: Void? = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepositoty_whenDownloadSuggestableQueries_updateLocal() {
        // given
        let expect = expectation(description: "검색가능한 리드아이템 단어 다운로드시에 로컬 업데이트")
        self.mockRemote.register(key: "requestLoadAllSearchableReadItemTexts") { Maybe<[String]>.just(["some"]) }
        self.mockLocal.called(key: "insertSuggestableQueries") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository.downloadAllSuggestableQueries(memberID: "some")
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testRespoitory_fetchAllSuggestableQueries() {
        // given
        let expect = expectation(description: "저장된 검색가능단어 모두 로드")
        self.mockLocal.register(key: "fetchAllSuggestableQueries") { Maybe<[String]>.just(["some"]) }
        
        // when
        let loading = self.repository.fetchAllSuggestableQueries()
        let queries = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertEqual(queries?.isNotEmpty, true)
    }
    
    func testRespoitory_insertSuggestableQueries() {
        // given
        let expect = expectation(description: "저장된 검색가능단어 추가")
        self.mockLocal.called(key: "insertSuggestableQueries") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository.insertSuggetableQueries(["some"])
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}

extension RepositoryTests_Search {
    
    class DummyRepository: IntegratedSearchReposiotry, IntegratedSearchReposiotryDefImpleDependency {
        
        let disposeBag: DisposeBag = .init()
        private let local: MockLocal
        private let remote: MockRemote
        
        var readItemRemote: ReadItemRemote {
            return self.remote
        }
        
        var readItemLocal: ReadItemLocalStorage {
            return self.local
        }
        
        var searchLocal: SearchLocalStorage {
            return self.local
        }
        
        init(local: MockLocal, remote: MockRemote) {
            self.local = local
            self.remote = remote
        }
    }
}
