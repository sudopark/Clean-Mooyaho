//
//  ReadingListItemRepositoryImple.swift
//  ReadingList
//
//  Created by sudo.park on 2022/08/19.
//

import Foundation

import RxSwift
import RxSwiftDoNotation
import Domain


public final class ReadingListItemRepositoryImple: ReadingListItemRepository {
    
    private let authInfoProvider: AuthInfoProviderV2
    private let local: ReadingListItemsLocal
    private let remote: ReadingListItemsRemote
    
    public init(
        authInfoProvider: AuthInfoProviderV2,
        local: ReadingListItemsLocal,
        remote: ReadingListItemsRemote
    ) {
        self.authInfoProvider = authInfoProvider
        self.local = local
        self.remote = remote
    }
}

extension ReadingListItemRepositoryImple {
    
    private var concatLoading: ConcatLoading<ReadingListItemsLocal, ReadingListItemsRemote> {
        return .init(self.authInfoProvider, self.local, self.remote)
    }
    
    public func loadItems(in ids: [String]) -> Observable<[ReadingListItem]> {
        
        return self.concatLoading.do { local in
            return try await local.loadItems(in: ids)
        } thenRemoteIfNeed: { remote, _ in
            return try await remote.loadItems(in: ids)
        } andRefreshCache: { local, newItems in
            try await local.saveItems(newItems)
        }
    }
}
