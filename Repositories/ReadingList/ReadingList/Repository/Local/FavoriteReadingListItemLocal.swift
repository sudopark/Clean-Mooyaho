//
//  FavoriteReadingListItemLocal.swift
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


public protocol FavoriteReadingListItemLocal: Sendable {
    
    func loadFavoriteItemIDs() async throws -> [String]
    
    func toggleIsFavorite(_ id: String, isOn: Bool) async throws
    
    func saveFavoriteItemIDs(_ ids: [String]) async throws
}


public final class FavoriteReadingListItemLocalImple: FavoriteReadingListItemLocal, Sendable {
    
    private let storage: SQLiteStorage
    public init(storage: SQLiteStorage) {
        self.storage = storage
    }
}


extension FavoriteReadingListItemLocalImple {
    
    private typealias IDs = FavoriteReadingListItemIDTable
    
    public func loadFavoriteItemIDs() async throws -> [String] {
            
        let query = IDs.selectAll()
        async let ids = self.storage.run { try $0.load(IDs.self, query: query) }
        return try await ids.map { $0.id }
    }
    
    public func toggleIsFavorite(_ id: String, isOn: Bool) async throws {
        let ids = try await self.loadFavoriteItemIDs()
        let newIDs = ids.filter{ $0 != id } + (isOn ? [id] : [])
        let entities = newIDs.map { IDs.Entity(id: $0) }
        
        try await self.storage.run { try $0.dropTable(IDs.self) }
        try await self.storage.run { try $0.insert(IDs.self, entities: entities) }
    }
    
    public func saveFavoriteItemIDs(_ ids: [String]) async throws {
        try await self.storage.run { try $0.dropTable(IDs.self) }
        let entities = ids.map { IDs.Entity(id: $0) }
        try await self.storage.run { try $0.insert(IDs.self, entities: entities) }
    }
}
