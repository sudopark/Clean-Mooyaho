//
//  ReadingListItemsLocal.swift
//  ReadingList
//
//  Created by sudo.park on 2022/08/17.
//

import Foundation

import Domain
import SQLiteService
import Local


public protocol ReadingListItemsLocal: Sendable {
    
    func loadItems(in ids: [String]) async throws -> [ReadingListItem]
    
    func saveItems(_ items: [ReadingListItem]) async throws
}


public final class ReadingListItemsLocalImple: ReadingListItemsLocal {
    
    private let storage: SQLiteStorage
    public init(storage: SQLiteStorage) {
        self.storage = storage
    }
}


extension ReadingListItemsLocalImple {
    
    private typealias Lists = ReadingListTable
    private typealias LinkItems = ReadLinkItemTable
    
    public func loadItems(in ids: [String]) async throws -> [ReadingListItem] {
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
}

extension ReadingListItemsLocalImple {
    
    public func saveItems(_ items: [ReadingListItem]) async throws {
        let lists = items.compactMap { $0 as? ReadingList }
        let links = items.compactMap { $0 as? ReadLinkItem }
        
        await self.saveLists(lists)
        await self.saveLinkItems(links)
    }
    
    private func saveLists(_ lists: [ReadingList]) async {
        let entities = lists.map { Lists.Entity(list: $0) }
        try? await self.storage.run { try $0.insert(Lists.self, entities: entities) }
    }
    
    private func saveLinkItems(_ links: [ReadLinkItem]) async {
        let entities = links.map { LinkItems.Entity(item: $0) }
        try? await self.storage.run { try $0.insert(LinkItems.self, entities: entities) }
    }
}
