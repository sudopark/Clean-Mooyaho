//
//  FavoriteReadingListItemRemoteImple.swift
//  ReadingList
//
//  Created by sudo.park on 2022/08/15.
//

import Foundation

import Domain
import Remote
import Extensions


public protocol FavoriteReadingListItemRemote: Sendable {
    
    func loadFavoriteItemIDs(for ownerID: String) async throws -> [String]
    
    func toggleIsFavorite(for ownerID: String, _ id: String, isOn: Bool) async throws
}

public final class FavoriteReadingListItemRemoteImple: FavoriteReadingListItemRemote, Sendable {
    
    private let restRemote: RestRemote
    public init(
        restRemote: RestRemote
    ) {
        self.restRemote = restRemote
    }
}

extension FavoriteReadingListItemRemoteImple {
    
    private typealias ListKey = ReadingListMappingKey
    private typealias LinkKey = ReadLinkItemMappingKey
    private typealias IDsKey = FavoriteMappingKey
    
    public func loadFavoriteItemIDs(for ownerID: String) async throws -> [String] {
        let endpoint = ReadingListEndpoints.favoriteItemIDs
        let idList: MemberFavoriteListItem = try await self.restRemote.requestFind(endpoint, byID: ownerID)
        return idList.ids
    }
    
    public func toggleIsFavorite(for ownerID: String, _ id: String, isOn: Bool) async throws {
        let endpoint = ReadingListEndpoints.updateFavoriteItemIDs
        let toJson: [String: Any] = [
            IDsKey.ids.rawValue: isOn ? UpdateList.union(elements: [id]) : UpdateList.remove(elements: [id])
        ]
        let _: MemberFavoriteListItem = try await self.restRemote.requestUpdate(endpoint, id: ownerID, to: toJson)
    }
}
