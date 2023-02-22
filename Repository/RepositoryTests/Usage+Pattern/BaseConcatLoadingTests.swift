//
//  BaseConcatLoadingTests.swift
//  RepositoryTests
//
//  Created by sudo.park on 2023/02/19.
//

import XCTest
import RxSwift
import Extensions
import UnitTestHelpKit

@testable import Repository


// MARK: - BaseSingleConcacatLoadingTests

class BaseSingleConcacatLoadingTests<Result>: BaseRepositoryUsageTests, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
    }
    
    // override needs
    func stubResult() { }
    func stubLoadFail() { }
    func loading() -> Observable<Result> { .empty() }
    func assertResult(_ result: Result?) -> Bool { return true }
}


extension BaseSingleConcacatLoadingTests {
    
    func testLoader_load() {
        // given
        let expect = expectation(description: "로드")
        self.stubResult()
        // when
        let loading = self.loading()
        let result = self.waitFirstElement(expect, for: loading)
        
        // then
        XCTAssertEqual(self.assertResult(result), true)
    }
    
    func testLoader_loadFail() {
        // given
        let expect = expectation(description: "로드 실패")
        self.stubLoadFail()
        
        // when
        let loading = self.loading()
        let error = self.waitError(expect, for: loading)
        
        // then
        XCTAssertNotNil(error)
    }
}


// MARK: - BaseDualStorageConcatLoadingTests

class BaseDualStorageConcatLoadingTests<Result>: BaseRepositoryUsageTests, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var didCacheUpdated: (() -> Void)?
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.didCacheUpdated = nil
    }
    
    // override needs
    func stubCacheResult() { }
    func stubNullCache() { }
    func stubCacheFail() { }
    func stubResult() { }
    func stubLoadFail() { }
    func stubUpdateCache() { }
    func stubUpdateCacheFail() { }
    func loading() -> Observable<Result> { .empty() }
    
    func assertResults(_ results: [Result]) -> Bool { return true }
    func assertNoCacheResults(_ results: [Result]) -> Bool { return true }
}


extension BaseDualStorageConcatLoadingTests {
 
    func testLoader_whenDual_loadFromCacheAndRemote() {
        // given
        let expect = expectation(description: "dual 일때 캐시에서 먼저, 이후 메인 스토리지에서")
        expect.expectedFulfillmentCount = 2
        self.stubCacheResult()
        self.stubResult()
        
        // when
        let load = self.loading()
        let results = self.waitElements(expect, for: load)
        
        // then
        XCTAssertEqual(self.assertResults(results), true)
    }
    
    func testLoader_whenDualAndCacheNotExists_justReturnMain() {
        // given
        let expect = expectation(description: "dual 일때 캐시에 없으면 메인 스토리지 결과만")
        self.stubNullCache()
        self.stubResult()
        
        // when
        let load = self.loading()
        let results = self.waitElements(expect, for: load)
        
        // then
        XCTAssertEqual(self.assertNoCacheResults(results), true)
    }
    
    func testLoader_whenDualAndFailToLoadFromCache_ignore() {
        // given
        let expect = expectation(description: "dual 일때 캐시 로드 에러나면 없는것으로 취급")
        self.stubCacheFail()
        self.stubResult()
        
        // when
        let load = self.loading()
        let results = self.waitElements(expect, for: load)
        
        // then
        XCTAssertEqual(self.assertNoCacheResults(results), true)
    }
    
    func testLoader_whenDualAndFailToLoadFromMain_fail() {
        // given
        let expect = expectation(description: "dual 일때 메인 에러나면 에러")
        self.stubCacheResult()
        self.stubLoadFail()
        
        // when
        let load = self.loading()
        let error = self.waitError(expect, for: load)
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testLoader_whenDualAndRefreshCacheNeed_refresh() {
        // given
        let expect = expectation(description: "dual 일때 메인 로드 이후에 캐시 업데이트")
        expect.assertForOverFulfill = false
        self.stubCacheResult()
        self.stubResult()
        self.stubUpdateCache()
        
        self.didCacheUpdated = {
            expect.fulfill()
        }
        
        // when + then
        let load = self.loading()
        
        load.subscribe()
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testLoader_whenRefreshCacheFail_ignore() {
        // given
        let expect = expectation(description: "dual 일때 캐시 업데이트 실패해도 무시")
        expect.expectedFulfillmentCount = 2
        self.stubCacheResult()
        self.stubResult()
        self.stubUpdateCacheFail()
        
        // when
        let load = self.loading()
        let results = self.waitElements(expect, for: load)
        
        // then
        XCTAssertEqual(self.assertResults(results), true)
    }
}
