//
//  LocalStorageTests+Search.swift
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


class LocalStorageTests_Search: BaseLocalStorageTests {
        
    func saveOldQueryJob() -> Observable<Void> {
        
        let queries = (0..<10).map { "t:\($0)" }
        let savingJobs = queries.map { self.local.insertLatestSearchQuery($0) }
        let emptySeed: Observable<Void> = .empty()
        return savingJobs.reduce(emptySeed) { acc, next in
            return acc.concat(next)
        }
        .takeLast(1)
    }
}

extension LocalStorageTests_Search {
    
    func testStorage_fetchLatestSearchQueries() {
        // given
        let expect = expectation(description: "저장된 최근 검색어 로드")
        
        // when
        let saveOld = self.saveOldQueryJob()
        let fetch = self.local.fetchLatestSearchedQueries().asObservable()
        let saveAndLoad = saveOld.flatMap { fetch }
        let queries = self.waitFirstElement(expect, for: saveAndLoad)
        
        // then
        XCTAssertEqual(queries?.count, 10)
    }
    
    func testStorage_updateLatestSearchedQuery() {
        // given
        let expect = expectation(description: "가장 최근에 검색한 쿼리 업데이트")
        
        // when
        let saveOld = self.saveOldQueryJob()
        let update = self.local.insertLatestSearchQuery("t:0")
        let load = self.local.fetchLatestSearchedQueries()
        let saveUpdateAndLoad = saveOld.flatMap { update.asObservable() }.flatMap { load.asObservable() }
        let queries = self.waitFirstElement(expect, for: saveUpdateAndLoad)
        
        // then
        let latest = queries?.first
        XCTAssertEqual(latest?.text, "t:0")
        XCTAssertEqual(queries?.count, 10)
    }
    
    func testStorage_insertAndDeleteQuery() {
        // given
        let expect = expectation(description: "저장된 쿼리 삭제")
        
        // when
        let save = self.local.insertLatestSearchQuery("some")
        let delete = self.local.removeLatestSearchQuery("some")
        let load = self.local.fetchLatestSearchedQueries()
        let saveDeleteAndload = save.flatMap { delete }.flatMap { load }
        let queries = self.waitFirstElement(expect, for: saveDeleteAndload.asObservable())
        
        // then
        XCTAssertEqual(queries?.isEmpty, true)
    }
    
    func testStorage_insertAndFetchAllSuggestableQueries() {
        // given
        let expect = expectation(description: "검색가능단어 저장하고 모두 로드")
        
        // when
        let insert = self.local.insertSuggestableQueries(["q1", "q2"])
        let fetch = self.local.fetchAllSuggestableQueries()
        let insertAndFetch = insert.flatMap { fetch }
        let queries = self.waitFirstElement(expect, for: insertAndFetch.asObservable())
        
        // then
        XCTAssertEqual(queries?.count, 2)
    }
}
