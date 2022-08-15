//
//  RemoteFavoriteReadingListItemRepositoryImple.swift
//  ReadingList
//
//  Created by sudo.park on 2022/08/15.
//

import Foundation

import Domain
import Remote
import Extensions

public final class RemoteFavoriteReadingListItemRepositoryImple: FavoriteReadingListItemRepository, Sendable {
    
    
    private let restRemote: RestRemote
    public init(restRemote: RestRemote) {
        self.restRemote = restRemote
    }
}

extension RemoteFavoriteReadingListItemRepositoryImple {
    
    private typealias ListKey = ReadingListMappingKey
    private typealias LinkKey = ReadLinkItemMappingKey
    private typealias IDsKey = FavoriteMappingKey
    
    public func loadFavoriteItemIDs(for ownerID: String?) async throws -> [String] {
        guard let ownerID else {
            throw RuntimeError("owner id is required for loading user favorite reaing list item")
        }
        let endpoint = ReadingListEndpoints.favoriteItemIDs
        let idList: MemberFavoriteListItem = try await self.restRemote.requestFind(endpoint, byID: ownerID)
        return idList.ids
    }
    
    public func loadFavoriteItems(for ownerID: String?) async throws -> [ReadingListItem] {
        let itemIDs = try await self.loadFavoriteItemIDs(for: ownerID)
        async let lists = self.loadLists(in: itemIDs)
        async let linkItems = self.loadLinkItems(in: itemIDs)
        return await lists + linkItems
    }
    
    private func loadLists(in ids: [String]) async -> [ReadingList] {
        let query = LoadQuery()
            .where(.init(ListKey.uid.rawValue, .in, ids))
        let endpoint = ReadingListEndpoints.lists
        return (try? await self.restRemote.requestFind(endpoint, byQuery: query)) ?? []
    }
    
    private func loadLinkItems(in ids: [String]) async -> [ReadingList] {
        let query = LoadQuery()
            .where(.init(LinkKey.uid.rawValue, .in, ids))
        let endpoint = ReadingListEndpoints.linkItems
        return (try? await self.restRemote.requestFind(endpoint, byQuery: query)) ?? []
    }
    
    public func toggleIsFavorite(for ownerID: String?, _ id: String, isOn: Bool) async throws {
        guard let ownerID else {
            throw RuntimeError("owner id is required for loading user favorite reaing list item")
        }
        let endpoint = ReadingListEndpoints.updateFavoriteItemIDs
        let toJson: [String: Any] = [
            IDsKey.ids.rawValue: isOn ? UpdateList.union(elements: [id]) : UpdateList.remove(elements: [id])
        ]
        let _: MemberFavoriteListItem = try await self.restRemote.requestUpdate(endpoint, id: ownerID, to: toJson)
    }
}
