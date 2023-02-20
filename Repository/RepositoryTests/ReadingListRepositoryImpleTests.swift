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


// MARK: - Load my list

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
        self.stubStorage.shouldFailLoadMyList = true
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
        self.stubCacheStorage.shouldLoadFailMyList = true
    }
    
    override func stubLoadFail() {
        self.stubStorage.shouldFailLoadMyList = true
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

// MARK: - Load list

class ReadingListRepositoryImple_SingleStorage_loadListTests: BaseSingleConcacatLoadingTests<ReadingList> {
    
    private var stubStorage: StubMainStorage!
    private var repository: ReadingListRepositoryImple!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.stubStorage = .init()
        self.repository = .init(self.stubStorage, nil)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        self.stubStorage = nil
        self.repository = nil
    }
    
    override func stubLoadFail() {
        self.stubStorage.shouldFailLoadList = true
    }
    
    override func loading() -> Observable<ReadingList> {
        return self.repository.loadList("some")
    }
    
    override func assertResult(_ result: ReadingList?) -> Bool {
        return result?.uuid == "some"
    }
    
    func testUsage() throws {
        try runTest {
            super.testLoader_load()
        }
        try runTest {
            super.testLoader_loadFail()
        }
    }
}

class ReadingListRepositoryImple_DualStorageTests_loadListTests: BaseDualStorageConcatLoadingTests<ReadingList> {
    
    private var stubStorage: StubMainStorage!
    private var stubCacheStorage: StubCacheStorage!
    private var repository: ReadingListRepositoryImple!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.stubStorage = .init()
        self.stubCacheStorage = .init()
        self.repository = .init(self.stubStorage, self.stubCacheStorage)
        self.stubCacheStorage.didListUpdated = { _ in
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
        self.stubCacheStorage.shouldFailLoadList = true
    }
    
    override func stubNullCache() {
        self.stubCacheStorage.listIsNotExists = true
    }
    
    override func stubLoadFail() {
        self.stubStorage.shouldFailLoadList = true
    }
    
    override func stubUpdateCacheFail() {
        self.stubCacheStorage.shouldFailUpdateList = true
    }
    
    override func loading() -> Observable<ReadingList> {
        return self.repository.loadList("some")
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


private class StubMainStorage: ReadingListStorage, @unchecked Sendable {
    
    var shouldFailLoadMyList: Bool = false
    func loadMyList() async throws -> ReadingList {
        if shouldFailLoadMyList {
            throw RuntimeError("failed")
        } else {
            return ReadingList(uuid: "some", name: "main")
        }
    }
    
    var shouldFailLoadList: Bool = false
    func loadList(_ listId: String) async throws -> ReadingList {
        if shouldFailLoadList {
             throw RuntimeError("failed")
        } else {
            return ReadingList(uuid: listId, name: "main")
        }
    }
}

private class StubCacheStorage: ReadingListCacheStorage, @unchecked Sendable {
    
    var shouldLoadFailMyList: Bool = false
    func loadMyList() async throws -> ReadingList {
        if shouldLoadFailMyList {
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
    
    var shouldFailLoadList: Bool = false
    var listIsNotExists: Bool = false
    func loadList(_ listId: String) async throws -> ReadingList? {
        if shouldFailLoadList {
            throw RuntimeError("failed")
        } else if listIsNotExists {
            return nil
        } else {
            return ReadingList(uuid: listId, name: "cache")
        }
    }
    
    var didListUpdated: ((String) -> Void)?
    var shouldFailUpdateList: Bool = false
    func updateList(_ list: ReadingList) async throws {
        self.didListUpdated?(list.uuid)
        if shouldFailUpdateList {
            throw RuntimeError("failed")
        }
    }
}
