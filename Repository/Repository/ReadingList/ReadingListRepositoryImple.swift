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
    
}

public protocol ReadingListCacheStorage: Sendable {
    
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
    
    public func loadMyList() -> Observable<ReadingList> {
        // 1. cache에서 로드
        // 2. main에서 로드
        // 3. cache 업데이트
        return .empty()
    }
    
    public func loadList(_ listID: String) -> Observable<ReadingList> {
        return .empty()
    }
    
    public func loadLinkItem(_ itemID: String) -> Observable<ReadLinkItem> {
        return .empty()
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
