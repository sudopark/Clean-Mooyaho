//
//  ReadingListRepositoryImple.swift
//  ReadingList
//
//  Created by sudo.park on 2022/08/19.
//

import Foundation
import RxSwift
import RxSwiftDoNotation

import Domain
import Extensions


public final class ReadingListRepositoryImple: ReadingListRepository, Sendable {
    
    private let authInfoProvider: AuthInfoProviderV2
    private let local: ReadingListLocal
    private let remote: ReadingListRemote
    
    public init(
        authInfoProvider: AuthInfoProviderV2,
        local: ReadingListLocal,
        remote: ReadingListRemote
    ) {
        self.authInfoProvider = authInfoProvider
        self.local = local
        self.remote = remote
    }
}

extension ReadingListRepositoryImple {
    
    private var concatLoading: ConcatLoading<ReadingListLocal, ReadingListRemote> {
        return .init(self.authInfoProvider, self.local, self.remote)
    }
    
    public func loadMyList() -> Observable<ReadingList> {
        
        return self.concatLoading.do { local in
            return try? await local.loadMyList()
        } thenRemoteIfNeed: { remote, ownerID in
            return try await remote.loadMyList(for: ownerID)
        } andRefreshCache: { local, list in
            try await local.updateMyList(list)
        }
    }
    
    public func loadList(_ listID: String) -> Observable<ReadingList> {
        
        return self.concatLoading.do { local in
            return try? await local.loadList(listID)
        } thenRemoteIfNeed: { remote, _ in
            return try await remote.loadList(listID)
        } andRefreshCache: { local, list in
            _ = try await local.updateList(list, withItems: list.items)
        }
    }
    
    public func loadLinkItem(_ itemID: String) -> Observable<ReadLinkItem> {
        
        return self.concatLoading.do { local in
            return try? await local.loadLinkItem(itemID)
        } thenRemoteIfNeed: { remote, _ in
            return try await remote.loadLinkItem(itemID)
        } andRefreshCache: { local, linkItem in
            _ = try await local.updateLinkItem(linkItem)
        }
    }
}

extension ReadingListRepositoryImple {
    
    private var switchUpdating: SwitchUpdating<ReadingListLocal, ReadingListRemote> {
        return SwitchUpdating(
            authInfoProvider: self.authInfoProvider,
            local: self.local,
            remote: self.remote
        )
    }
    
    public func saveList(_ readingList: ReadingList,
                         at parentListID: String?) async throws -> ReadingList {
        
        return try await self.switchUpdating.do { remote, _ in
            return try await remote.saveList(readingList, at: parentListID)
        } andUpdateCache: { local, newList in
            _ = try await local.saveList(newList, at: parentListID)
        } orUpdateOnLocal: { local in
            return try await local.saveList(readingList, at: parentListID)
        }
    }
    
    public func saveLinkItem(_ item: ReadLinkItem,
                             to listID: String?) async throws -> ReadLinkItem {
        
        return try await self.switchUpdating.do { remote, _ in
            return try await remote.saveLinkItem(item, to: listID)
        } andUpdateCache: { local, newItem in
            _ = try await local.saveLinkItem(newItem, to: listID)
        } orUpdateOnLocal: { local in
            return try await local.saveLinkItem(item, to: listID)
        }
    }
    
    public func updateList(_ readingList: ReadingList) async throws -> ReadingList {
        
        return try await self.switchUpdating.do { remote, _ in
            return try await remote.updateList(readingList)
        } andUpdateCache: { local, newList in
            _ = try await local.updateList(newList, withItems: nil)
        } orUpdateOnLocal: { local in
            return try await local.updateList(readingList, withItems: nil)
        }
    }
    
    public func updateLinkItem(_ item: ReadLinkItem) async throws -> ReadLinkItem {
        
        return try await self.switchUpdating.do { remote, _ in
            return try await remote.updateLinkItem(item)
        } andUpdateCache: { local, newItem in
            _ = try await local.updateLinkItem(newItem)
        } orUpdateOnLocal: { local in
            return try await local.updateLinkItem(item)
        }
    }
}


extension ReadingListRepositoryImple {
    
    public func removeList(_ id: String) async throws {
        
        return try await self.switchUpdating.do { remote, _ in
            return try await remote.removeList(id)
        } andUpdateCache: { local, _ in
            return try await local.removeList(id)
        } orUpdateOnLocal: { local in
            return try await local.removeList(id)
        }
    }
    
    public func removeLinkItem(_ id: String) async throws {
        
        return try await self.switchUpdating.do { remote, _ in
            return try await remote.removeLinkItem(id)
        } andUpdateCache: { local, _ in
            return try await local.removeLinkItem(id)
        } orUpdateOnLocal: { local in
            return try await local.removeLinkItem(id)
        }
    }
}
