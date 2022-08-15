//
//  LocalReadingListRepositoryImple.swift
//  ReadingList
//
//  Created by sudo.park on 2022/07/02.
//

import Foundation

import Domain
import Extensions
import Local
import SQLiteService
import Prelude
import Optics


public final class LocalReadingListRepositoryImple: ReadingListRepository, Sendable {
    
    private let storage: SQLiteStorage
    public init(storage: SQLiteStorage) {
        self.storage = storage
    }
}


// MARK: - Load

extension LocalReadingListRepositoryImple {
    
    private typealias Lists = ReadingListTable
    private typealias LinkItem = ReadLinkItemTable
    
    public func loadMyList(for ownerID: String?) async throws -> ReadingList {
        return try await ReadingList.makeMyRootList(ownerID)
            |> \.items .~ self.loadListSubItems(nil)
    }
    
    public func loadList(_ listID: String) async throws -> ReadingList {
        
        let query = Lists.selectAll { $0.uid == listID }
        guard let list = (try? await self.loadLists(query).first)
        else{
            throw RuntimeError("list not exists => \(listID)")
        }
        
        return try await list
            |> \.items .~ self.loadListSubItems(listID)
    }
    
    public func loadLinkItem(_ itemID: String) async throws -> ReadLinkItem {
        let query = LinkItem.selectAll { $0.uid == itemID }
        guard let item = try await self.loadLinkItems(query).first
        else {
            throw RuntimeError("link item not exists")
        }
        return item
    }
    
    private func loadListSubItems(_ listID: String?) async throws -> [ReadingListItem] {
        let subListsQuery: SelectQuery<Lists> = listID
            .map { id in Lists.selectAll { $0.parentID == id }} ?? Lists.selectAll { $0.parentID.isNull() }
        let subLinkItemsQuery: SelectQuery<LinkItem> = listID
            .map { id in LinkItem.selectAll { $0.parentID == id } } ?? LinkItem.selectAll { $0.parentID.isNull() }

        async let subLists = (try? self.loadLists(subListsQuery)) ?? []
        async let subLinkItems = (try? self.loadLinkItems(subLinkItemsQuery)) ?? []
        return await subLists + subLinkItems
    }
    
    private func loadLists(_ query: SelectQuery<ReadingListTable>) async throws -> [ReadingList] {
        let mapping: (ReadingListTable.Entity) -> ReadingList = { $0.asList() }
        return try await self.storage.run { try $0.load(query).map(mapping) }
    }
    
    private func loadLinkItems(_ query: SelectQuery<ReadLinkItemTable>) async throws -> [ReadLinkItem] {
        let mapping: (ReadLinkItemTable.Entity) throws -> ReadLinkItem = { $0.asLinkItem() }
        return try await self.storage.run { try $0.load(query).map(mapping) }
    }
}


// MARK: - update

extension LocalReadingListRepositoryImple {
    
    public func saveList(_ readingList: ReadingList,
                         at parentListID: String?) async throws -> ReadingList {
        let entity = Lists.Entity(list: readingList, parentID: parentListID)
        try await self.storage
            .run { try $0.insertOne(Lists.self, entity: entity, shouldReplace: true) }
        return readingList
    }
    
    public func updateList(_ readingList: ReadingList) async throws -> ReadingList {
        let query: UpdateQuery<Lists> = Lists.update {[
            $0.ownerID == readingList.ownerID,
            $0.name == readingList.name,
            $0.description == readingList.description,
            $0.createdAt == readingList.createdAt,
            $0.lastUpdatedAt == readingList.lastUpdatedAt,
            $0.pritority == readingList.priorityID,
            $0.categoryIDs == (try? readingList.categoryIds.asArrayText()) ?? ""
        ]}
        .where { $0.uid == readingList.uuid }
        try await self.storage.run { try $0.update(Lists.self, query: query)}
        return readingList
    }
    
    public func removeList(_ id: String) async throws {
        let query = Lists.delete().where { $0.uid == id }
        try await self.storage.run { try $0.delete(ReadingListTable.self, query: query) }
    }
    
    public func saveLinkItem(_ item: ReadLinkItem, to listID: String?) async throws -> ReadLinkItem {
        let item = item |> \.listID .~ listID
        let entity = LinkItem.Entity(item: item)
        try await self.storage
            .run { try $0.insertOne(LinkItem.self, entity: entity, shouldReplace: true) }
        return item
    }
    
    public func updateLinkItem(_ item: ReadLinkItem) async throws -> ReadLinkItem {
        let query: UpdateQuery<LinkItem> = LinkItem.update{[
            $0.ownerID == item.ownerID,
            $0.parentID == item.listID,
            $0.link == item.link,
            $0.createdAt == item.createdAt,
            $0.lastUpdatedAt == item.lastUpdatedAt,
            $0.customName == item.customName,
            $0.pritority == item.priorityID,
            $0.categoryIDs == (try? item.categoryIds.asArrayText()) ?? "",
            $0.isRed == item.isRead
        ]}
        .where { $0.uid == item.uuid }
        try await self.storage.run { try $0.update(LinkItem.self, query: query) }
        return item
    }
    
    public func removeLinkItem(_ id: String) async throws {
        let query = LinkItem.delete().where { $0.uid == id }
        try await self.storage.run { try $0.delete(LinkItem.self, query: query) }
    }
}
