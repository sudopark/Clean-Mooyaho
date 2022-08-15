//
//  LocalFavoriteReadingListItemRepositoryImple.swift
//  ReadingList
//
//  Created by sudo.park on 2022/08/15.
//

import Foundation


import Domain
import Extensions
import Local
import SQLiteService
import Prelude
import Optics


public final class LocalFavoriteReadingListItemRepositoryImple: FavoriteReadingListItemRepository, Sendable {
    
    private let storage: SQLiteStorage
    public init(storage: SQLiteStorage) {
        self.storage = storage
    }
}


extension LocalFavoriteReadingListItemRepositoryImple {
    
    private typealias IDs = FavoriteReadingListItemIDTable
    private typealias Lists = ReadingListTable
    private typealias LinkItems = ReadLinkItemTable
    
    public func loadFavoriteItemIDs(for ownerID: String?) async throws -> [String] {
            
        let query = IDs.selectAll()
        async let ids = self.storage.run { try $0.load(IDs.self, query: query) }
        return try await ids.map { $0.id }
    }
    
    public func loadFavoriteItems(for ownerID: String?) async throws -> [ReadingListItem] {
        let ids = try await self.loadFavoriteItemIDs(for: ownerID)
        async let lists = self.loadLists(in: ids)
        async let linkItems = self.loadLinkItems(in: ids)
        return await lists + linkItems
    }
    
    private func loadLists(in ids: [String]) async -> [ReadingList] {
        let query = Lists.selectAll { $0.uid.in(ids) }
        let mapping: (Lists.Entity) throws -> ReadingList = { $0.asList() }
        return (try? await self.storage.run { try $0.load(query).map(mapping) }) ?? []
    }
    
    private func loadLinkItems(in ids: [String]) async -> [ReadLinkItem] {
        let query = LinkItems.selectAll { $0.uid.in(ids) }
        let mapping: (LinkItems.Entity) throws -> ReadLinkItem = { $0.asLinkItem() }
        return (try? await self.storage.run { try $0.load(query).map(mapping) }) ?? []
    }
    
    public func toggleIsFavorite(for ownerID: String?, _ id: String, isOn: Bool) async throws {
        let ids = try await self.loadFavoriteItemIDs(for: ownerID)
        let newIDs = ids.filter{ $0 != id } + (isOn ? [id] : [])
        let entities = newIDs.map { IDs.Entity(id: $0) }
        
        try await self.storage.run { try $0.dropTable(IDs.self) }
        try await self.storage.run { try $0.insert(IDs.self, entities: entities) }
    }
}
