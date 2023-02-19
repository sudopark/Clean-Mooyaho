//
//  ReadingListRepositoryImpleTests.swift
//  RepositoryTests
//
//  Created by sudo.park on 2023/02/19.
//

import XCTest
import RxSwift
import Domain
import Extensions
import UnitTestHelpKit

@testable import Repository


class ReadingListRepositoryImple_SingleStorage_loadMyListTests: BaseSingleConcacatLoadingTests<ReadingList> {
    
    private var stubStorage: StubMainStorage!
    private var repository: ReadingListRepositoryImple!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.stubStorage = .init()
        self.repository = .init(self.stubStorage, nil)
    }
    
    override func tearDownWithError() throws {
        self.repository = nil
        self.stubStorage = nil
        try super.tearDownWithError()
    }
    
    override func stubLoadFail() {
        self.stubStorage.shouldFail = true
    }
    
    override func loading() -> Observable<ReadingList> {
        return self.repository.loadMyList()
    }
    
    override func assertResult(_ result: ReadingList?) -> Bool {
        return result?.uuid == "some"
    }
    
    func testUsages() throws {
        try self.runTest {
            super.testLoader_load()
        }
        
        try self.runTest {
            super.testLoader_loadFail()
        }
    }
}


class ReadingListRepositoryImple_DualStorageTests_loadMyListTests: BaseDualStorageConcatLoadingTests<ReadingList> {
    
    private var stubStorage: StubMainStorage!
    private var stubCacheStorage: StubCacheStorage!
    private var repository: ReadingListRepositoryImple!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.stubStorage = .init()
        self.stubCacheStorage = .init()
        self.repository = .init(self.stubStorage, self.stubCacheStorage)
        self.stubCacheStorage.didMyListUpdated = {
            super.didCacheUpdated?()
        }
    }
    
    override func tearDownWithError() throws {
        self.repository = nil
        self.stubStorage = nil
        self.stubCacheStorage = nil
        try super.tearDownWithError()
    }
    
    override func stubCacheFail() {
        self.stubCacheStorage.shouldLoadFail = true
    }
    
    override func stubLoadFail() {
        self.stubStorage.shouldFail = true
    }
    
    override func stubUpdateCacheFail() {
        self.stubCacheStorage.shouldFailUpdateMyList = true
    }
    
    override func loading() -> Observable<ReadingList> {
        return self.repository.loadMyList()
    }
    
    override func assertResults(_ results: [ReadingList]) -> Bool {
        return results.map { $0.name } == ["cache", "main"]
    }
    
    override func assertNoCacheResults(_ results: [ReadingList]) -> Bool {
        return results.map { $0.name } == ["main"]
    }
    
    func testUsage() throws {
        try self.runTest {
            super.testLoader_whenDual_loadFromCacheAndRemote()
        }
        try self.runTest {
            super.testLoader_whenDualAndFailToLoadFromCache_ignore()
        }
        try self.runTest {
            super.testLoader_whenDualAndFailToLoadFromMain_fail()
        }
        try self.runTest {
            super.testLoader_whenDualAndRefreshCacheNeed_refresh()
        }
        try self.runTest {
            super.testLoader_whenRefreshCacheFail_ignore()
        }
    }
}

private class StubMainStorage: ReadingListStorage {
    
    var shouldFail: Bool = false
    func loadMyList() async throws -> ReadingList {
        if shouldFail {
            throw RuntimeError("failed")
        } else {
            return ReadingList(uuid: "some", name: "main")
        }
    }
}

private class StubCacheStorage: ReadingListCacheStorage {
    
    var shouldLoadFail: Bool = false
    func loadMyList() async throws -> ReadingList {
        if shouldLoadFail {
            throw RuntimeError("failed")
        } else {
            return ReadingList(uuid: "some", name: "cache")
        }
    }
    
    var didMyListUpdated: (() -> Void)?
    var shouldFailUpdateMyList: Bool = false
    func updateMyList(_ list: ReadingList) async throws {
        didMyListUpdated?()
        if shouldFailUpdateMyList {
            throw RuntimeError("failed")
        }
    }
}
