//
//  ConcatLoaderTests.swift
//  RepositoryTests
//
//  Created by sudo.park on 2023/02/18.
//

import XCTest
import RxSwift
import RxSwiftDoNotation
import Extensions
import UnitTestHelpKit

@testable import Repository


class ConcatLoaderTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    private var spyCacheStorage: StubStorage!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyCacheStorage = nil
    }
}

// MARK: - single storage

extension ConcatLoaderTests {
    
    private func makeSingleStorageLoader() -> ConcatLoader<StubStorage, StubStorage> {
        return .init(mainStroage: StubStorage(), cacheStorage: nil)
    }
    
    func testLoader_whenSingle_loadFromMainStorage() {
        // given
        let expect = expectation(description: "single일때 메인스토리지만 이용 => 이벤트 하나")
        let loader = self.makeSingleStorageLoader()
        
        // when
        let load = loader.load(fromMain: { try await $0.load() } )
        let result = self.waitFirstElement(expect, for: load)
        
        // then
        XCTAssertEqual(result, 100)
    }
    
    func testLoader_whenSingleAndLoadFromMainFail_fail() {
        // given
        let expect = expectation(description: "single 일때 조회 실패하면 에러")
        let loader = self.makeSingleStorageLoader()
        
        // when
        let load = loader.load(fromMain: { _ in throw RuntimeError("some") })
        let error = self.waitError(expect, for: load)
        
        // then
        XCTAssertNotNil(error)
    }
}


// MARK: - dual storage

extension ConcatLoaderTests {
    
    private func makeDualStorageLoader() -> ConcatLoader<StubStorage, StubStorage> {
        let cache = StubStorage()
        self.spyCacheStorage = cache
        return .init(mainStroage: StubStorage(), cacheStorage: cache)
    }
    
    func testLoader_whenDual_loadFromCacheAndRemote() {
        // given
        let expect = expectation(description: "dual 일때 캐시에서 먼저, 이후 메인 스토리지에서")
        expect.expectedFulfillmentCount = 2
        let loader = self.makeDualStorageLoader()
        
        // when
        let load = loader.load { try await $0.load() } fromMain: { try await $0.load() }
        let results = self.waitElements(expect, for: load)
        
        // then
        XCTAssertEqual(results, [100, 100])
    }
    
    func testLoader_whenDualAndCacheNotExists_justReturnMain() {
        // given
        let expect = expectation(description: "dual 일때 캐시에 없으면 메인 스토리지 결과만")
        let loader = self.makeDualStorageLoader()
        
        // when
        let load = loader.load { _ in nil } fromMain: { try await $0.load() }
        let results = self.waitElements(expect, for: load)
        
        // then
        XCTAssertEqual(results, [100])
    }
    
    func testLoader_whenDualAndFailToLoadFromCache_ignore() {
        // given
        let expect = expectation(description: "dual 일때 캐시 로드 에러나면 없는것으로 취급")
        let loader = self.makeDualStorageLoader()
        
        // when
        let load = loader.load { _ in throw RuntimeError("some") } fromMain: { try await $0.load() }
        let results = self.waitElements(expect, for: load)
        
        // then
        XCTAssertEqual(results, [100])
    }
    
    func testLoader_whenDualAndFailToLoadFromMain_fail() {
        // given
        let expect = expectation(description: "dual 일때 메인 에러나면 에러")
        let loader = self.makeDualStorageLoader()
        
        // when
        let load = loader.load{ try? await $0.load() } fromMain: { _ in throw RuntimeError("some") }
        let error = self.waitError(expect, for: load)
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testLoader_whenDualAndRefreshCacheNeed_refresh() {
        // given
        let expect = expectation(description: "dual 일때 메인 로드 이후에 캐시 업데이트")
        let loader = self.makeDualStorageLoader()
        
        self.spyCacheStorage.didRefreshed = {
            expect.fulfill()
        }
        
        // when + then
        let load = loader.load {
            try await $0.load()
        } fromMain: {
            try await $0.load()
        } and: {
            try await $0?.refresh($1)
        }
        
        load.subscribe()
            .disposed(by: self.disposeBag)
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testLoader_whenRefreshCacheFail_ignore() {
        // given
        let expect = expectation(description: "dual 일때 캐시 업데이트 실패해도 무시")
        let loader = self.makeDualStorageLoader()
        
        // when
        let load = loader.load(fromMain: {
            try await $0.load()
        }, and: { _, _ in
            throw RuntimeError("some")
        })
        let result = self.waitElements(expect, for: load)
        
        // then
        XCTAssertEqual(result, [100])
    }
}

private extension ConcatLoaderTests {
    
    class StubStorage {
        func load() async throws -> Int {
            return 100
        }
        
        var didRefreshed: (() -> Void)?
        func refresh(_ int: Int) async throws {
            self.didRefreshed?()
        }
    }
}

