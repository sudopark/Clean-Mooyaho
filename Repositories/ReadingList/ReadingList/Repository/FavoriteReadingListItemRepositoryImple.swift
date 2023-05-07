//
//  FavoriteReadingListItemRepositoryImple.swift
//  ReadingList
//
//  Created by sudo.park on 2022/08/17.
//

import Foundation

import Domain
import RxSwift
import AsyncAlgorithms


public final class FavoriteReadingListItemRepositoryImple: FavoriteReadingListItemRepository {
    
    private let authInfoProvider: AuthInfoProviderV2
    private let local: FavoriteReadingListItemLocal
    private let remote: FavoriteReadingListItemRemote
    
    public init(
        authInfoProvider: AuthInfoProviderV2,
        local: FavoriteReadingListItemLocal,
        remote: FavoriteReadingListItemRemote
    ) {
        self.authInfoProvider = authInfoProvider
        self.local = local
        self.remote = remote
    }
}

extension FavoriteReadingListItemRepositoryImple {
    
    private var concatLoading: ConcatLoading<FavoriteReadingListItemLocal, FavoriteReadingListItemRemote> {
        return .init(self.authInfoProvider, self.local, self.remote)
    }
    
    public func loadFavoriteItemIDs() -> Observable<[String]> {
        
        return self.concatLoading.do { local in
            return try await local.loadFavoriteItemIDs()
        } thenRemoteIfNeed: { remote, userID in
            return try await remote.loadFavoriteItemIDs(for: userID)
        } andRefreshCache: { local, newIDs in
            return try await local.saveFavoriteItemIDs(newIDs)
        }
    }
    
    private var switchUpdating: SwitchUpdating<FavoriteReadingListItemLocal, FavoriteReadingListItemRemote> {
        return .init(authInfoProvider: self.authInfoProvider, local: self.local, remote: self.remote)
    }
    
    public func toggleIsFavorite(_ id: String, isOn: Bool) async throws {
        
        return try await self.switchUpdating.do { remote, ownerID in
            return try await remote.toggleIsFavorite(for: ownerID, id, isOn: isOn)
        } andUpdateCache: { local, _ in
            return try await local.toggleIsFavorite(id, isOn: isOn)
        } orUpdateOnLocal: { local in
            return try await local.toggleIsFavorite(id, isOn: isOn)
        }
    }
}
