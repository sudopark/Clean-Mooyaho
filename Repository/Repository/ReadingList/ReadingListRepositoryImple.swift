//
//  ReadingListRepositoryImple.swift
//  Repository
//
//  Created by sudo.park on 2023/02/18.
//

import Foundation
import RxSwift
import RxSwiftDoNotation
import Domain
import Extensions


public protocol ReadingListStorage: Sendable {
    
    func loadMyList() async throws -> ReadingList
    func loadList(_ listId: String) async throws -> ReadingList
    func loadLinkItem(_ itemId: String) async throws -> ReadLinkItem
}

public protocol ReadingListCacheStorage: Sendable {
    
    func loadMyList() async throws -> ReadingList
    func updateMyList(_ list: ReadingList) async throws
    
    func loadList(_ listId: String) async throws -> ReadingList?
    func updateList(_ list: ReadingList) async throws
    
    func loadLinkItem(_ itemId: String) async throws -> ReadLinkItem?
    func updateLinkItem(_ item: ReadLinkItem) async throws
}

public final class ReadingListRepositoryImple: ReadingListRepository, Sendable {
    
    private let mainStorage: ReadingListStorage
    private let cacheStorage: ReadingListCacheStorage?
    
    
    public init(_ mainStorage: ReadingListStorage,
                _ cacheStorage: ReadingListCacheStorage?) {
        self.mainStorage = mainStorage
        self.cacheStorage = cacheStorage
    }
}

// MARK: - load

extension ReadingListRepositoryImple {
    
    private func makeConcatLoader() -> ConcatLoader<ReadingListStorage, ReadingListCacheStorage> {
        return .init(mainStroage: self.mainStorage, cacheStorage: self.cacheStorage)
    }
    
    public func loadMyList() -> Observable<ReadingList> {
        let loader = self.makeConcatLoader()
        return loader.load {
            try await $0.loadMyList()
        } fromMain: {
            try await $0.loadMyList()
        } and: {
            try await $0?.updateMyList($1)
        }
    }
    
    public func loadList(_ listID: String) -> Observable<ReadingList> {
        let loader = self.makeConcatLoader()
        return loader.load {
            try await $0.loadList(listID)
        } fromMain: {
            try await $0.loadList(listID)
        } and: {
            try await $0?.updateList($1)
        }
    }
    
    public func loadLinkItem(_ itemID: String) -> Observable<ReadLinkItem> {
        let loader = self.makeConcatLoader()
        return loader.load {
            try await $0.loadLinkItem(itemID)
        } fromMain: {
            try await $0.loadLinkItem(itemID)
        } and: {
            try await $0?.updateLinkItem($1)
        }
    }
}


// MARK: - write + update

extension ReadingListRepositoryImple {
    
    public func saveList(_ readingList: ReadingList, at parentListID: String?) async throws -> ReadingList {
        throw RuntimeError("some")
    }
    
    public func saveLinkItem(_ item: ReadLinkItem, to listID: String?) async throws -> ReadLinkItem {
        throw RuntimeError("some")
    }
    
    public func updateList(_ readingList: ReadingList) async throws -> ReadingList {
        throw RuntimeError("some")
    }
    
    public func updateLinkItem(_ item: ReadLinkItem) async throws -> ReadLinkItem {
        throw RuntimeError("some")
    }
}


extension ReadingListRepositoryImple {
    
    public func removeList(_ id: String) async throws {
        throw RuntimeError("some")
    }
    
    public func removeLinkItem(_ id: String) async throws {
        throw RuntimeError("some")
    }
}
