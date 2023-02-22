//
//  SwitchUpdaterTests.swift
//  RepositoryTests
//
//  Created by sudo.park on 2023/02/21.
//

import XCTest

import RxSwift
import Extensions
import UnitTestHelpKit

@testable import Repository

class SwitchUpdaterTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    private var spyCache: StubStorage?
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.spyCache = nil
        self.disposeBag = nil
    }
}

// MARK: - single storage

extension SwitchUpdaterTests {
    
    private func makeSingleStorageUpdater() -> SwitchUpdater<StubStorage, StubStorage> {
        return .init(mainStorage: StubStorage(), cacheStorage: nil)
    }
    
    func testStorage_whenSingle_update() async {
        // given
        let updater = self.makeSingleStorageUpdater()
        
        // when
        let result = try? await updater.update {
            try await $0.update(100)
        }
        
        // then
        XCTAssertEqual(result, 100)
    }
    
    func testStorage_whenSingle_updateFail() async {
        // given
        let updater = self.makeSingleStorageUpdater()
        
        // when
        let result = try? await updater.update { _ -> Int in
            throw RuntimeError("failed")
        }
        
        // then
        XCTAssertNil(result)
    }
}

// MARK: - dual storage

extension SwitchUpdaterTests {
    
    private func makeDualStorageUpdater() -> SwitchUpdater<StubStorage, StubStorage> {
        let cache = StubStorage()
        self.spyCache = cache
        return .init(mainStorage: StubStorage(), cacheStorage: cache)
    }
    
    // main업데이트하고 캐시도 같이 업데이트함
    func testStorage_whenDual_updateMainAndCacheStorage() {
        // given
        let expect = expectation(description: "듀얼일때 메인업데이트하고 캐시도 업데이트함")
        let expectCacheUpdate = expectation(description: "캐시 업데이트 대기")
        let updater = self.makeDualStorageUpdater()
        
        // when
        self.spyCache?.didUpdated = {
            expectCacheUpdate.fulfill()
        }
        let updating = Observable<Int>.create {
            try await updater.update {
                try await $0.update(100)
            } and: {
                _ = try await $0?.update($1)
            }
        }
        let result = self.waitFirstElement(expect, for: updating)
        self.wait(for: [expectCacheUpdate], timeout: self.timeout)
        
        // then
        XCTAssertEqual(result, 100)
    }
    
    // 캐시 업데이트 실패해도 무시
    func testStorage_whenDualAndUpdateCacheFail_ignore() async {
        // given
        let updater = self.makeDualStorageUpdater()
        
        // when
        let result = try? await updater.update {
            try await $0.update(100)
        } and: { _, _ in
            throw RuntimeError("some")
        }
        
        // then
        XCTAssertEqual(result, 100)
    }
    
    // 메인 업데이트 실패하면 실패
    func testStorage_whenDualAndUpdateMainStorageFail_fail() async {
        // given
        let updater = self.makeDualStorageUpdater()
        
        // when
        let result = try? await updater.update { _ in
            throw RuntimeError("some")
        } and: {
            _ = try await $0?.update($1)
        }
        
        // then
        XCTAssertNil(result)
    }
}

private extension SwitchUpdaterTests {
    
    class StubStorage {
        
        var didUpdated: (() -> Void)?
        func update(_ int: Int) async throws -> Int {
            self.didUpdated?()
            return int
        }
    }
}
