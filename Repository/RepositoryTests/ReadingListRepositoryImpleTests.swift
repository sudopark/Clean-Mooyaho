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
            super.testLoader_whenDualAndCacheNotExists_justReturnMain()
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


// MARK: - Load Link item

class ReadingListRepositoryImple_SingleStorage_loadLinkItemTests: BaseSingleConcacatLoadingTests<ReadLinkItem> {
    
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
        self.stubStorage.shouldFailLoadLinkItem = true
    }
    
    override func loading() -> Observable<ReadLinkItem> {
        return self.repository.loadLinkItem("some")
    }
    
    override func assertResult(_ result: ReadLinkItem?) -> Bool {
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

class ReadingListRepositoryImple_DualStorageTests_loadLinkItemTests: BaseDualStorageConcatLoadingTests<ReadLinkItem> {
    
    private var stubStorage: StubMainStorage!
    private var stubCacheStorage: StubCacheStorage!
    private var repository: ReadingListRepositoryImple!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.stubStorage = .init()
        self.stubCacheStorage = .init()
        self.repository = .init(self.stubStorage, self.stubCacheStorage)
        self.stubCacheStorage.didUpdateLinkItem = {
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
        self.stubCacheStorage.shouldFailLoadLinkItem = true
    }
    
    override func stubNullCache() {
        self.stubCacheStorage.itemisNotExists = true
    }
    
    override func stubLoadFail() {
        self.stubStorage.shouldFailLoadLinkItem = true
    }
    
    override func stubUpdateCacheFail() {
        self.stubCacheStorage.shouldFailUpdateLinkItem = true
    }
    
    override func loading() -> Observable<ReadLinkItem> {
        return self.repository.loadLinkItem("some")
    }
    
    override func assertResults(_ results: [ReadLinkItem]) -> Bool {
        return results.map { $0.link } == ["cache", "main"]
    }
    
    override func assertNoCacheResults(_ results: [ReadLinkItem]) -> Bool {
        return results.map { $0.link } == ["main"]
    }
    
    func testUsage() throws {
        try self.runTest {
            super.testLoader_whenDual_loadFromCacheAndRemote()
        }
        try self.runTest {
            super.testLoader_whenDualAndCacheNotExists_justReturnMain()
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

// MARK: - Save List

class ReadingListRepositoryImple_SingleStorage_SaveListTests: BaseSingleSwitchUpdatingTests<ReadingList> {
    
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
    
    override func stubFail() {
        self.stubStorage.shouldFailSaveList = true
    }
    
    override func updating() async throws -> ReadingList {
        return try await self.repository.saveList(.init(uuid: "some", name: "main"), at: "parent")
    }
    
    override func assertResult(_ result: ReadingList?) -> Bool {
        return result?.uuid == "some"
    }
    
    func testUsage() async throws {
        try await self.runAsyncTest {
            await super.testUpdater_save()
        }
        try await self.runAsyncTest {
            await super.testUpdater_saveFail()
        }
    }
}

class ReadingListRepositoryImple_DualStorageTests_SaveListTests: BaseDualSwitchUpdatingTests<ReadingList> {
    
    private var stubStorage: StubMainStorage!
    private var stubCacheStorage: StubCacheStorage!
    private var repository: ReadingListRepositoryImple!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.stubStorage = .init()
        self.stubCacheStorage = .init()
        self.repository = .init(self.stubStorage, self.stubCacheStorage)
        self.stubCacheStorage.didSaveList = {
            super.didCacheUpdated?()
        }
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        self.repository = nil
        self.stubStorage = nil
        self.stubCacheStorage = nil
    }
    
    override func stubFailUpdate() {
        self.stubStorage.shouldFailSaveList = true
    }
    
    override func stubCacheFailUpdate() {
        self.stubCacheStorage.shouldFailSaveList = true
    }
    
    override func updating() async throws -> ReadingList {
        return try await self.repository.saveList(.init(uuid: "some", name: "name"), at: "parent")
    }
    
    override func assertResult(_ result: ReadingList?) -> Bool {
        return result?.uuid == "some"
    }
    
    func testUsage() async throws {
        
        try await runAsyncTest {
            await super.testUpdater_update()
        }
        try await runAsyncTest {
            await super.testUpdater_whenUpdateMainStorageFail_fail()
        }
        try await runAsyncTest {
            await super.testUpdater_whenUpdateCacheFail_ignore()
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
    
    var shouldFailLoadLinkItem: Bool = false
    func loadLinkItem(_ itemId: String) async throws -> ReadLinkItem {
        if shouldFailLoadLinkItem {
            throw RuntimeError("failed")
        } else {
            return ReadLinkItem(uuid: itemId, link: "main")
        }
    }
    
    var shouldFailSaveList: Bool = false
    func saveList(_ list: ReadingList, at parentId: String?) async throws -> ReadingList {
        if self.shouldFailSaveList {
            throw RuntimeError("failed")
        } else {
            return list
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
    
    var shouldFailLoadLinkItem: Bool = false
    var itemisNotExists: Bool = false
    func loadLinkItem(_ itemId: String) async throws -> ReadLinkItem? {
        if shouldFailLoadLinkItem {
            throw RuntimeError("failed")
        } else if itemisNotExists {
            return nil
        } else {
            return ReadLinkItem(uuid: itemId, link: "cache")
        }
    }
    
    var didUpdateLinkItem: (() -> Void)?
    var shouldFailUpdateLinkItem: Bool = false
    func updateLinkItem(_ item: ReadLinkItem) async throws {
        self.didUpdateLinkItem?()
        if shouldFailUpdateLinkItem {
            throw RuntimeError("failed")
        }
    }
    
    var shouldFailSaveList: Bool = false
    var didSaveList: (() -> Void)?
    func saveList(_ list: ReadingList, at parentId: String?) async throws  {
        self.didSaveList?()
        if self.shouldFailSaveList {
            throw RuntimeError("failed")
        }
    }
}
