//
//  DataModelStorage+UserDataMigration.swift
//  DataStore
//
//  Created by sudo.park on 2021/11/06.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import SQLiteService

import Domain


extension DataModelStorageImple {
    
    public func fetch<T>(_ type: T.Type, with size: Int) -> Maybe<[T]> {
        
        let typeName = String(describing: type.self)
        switch typeName {
        case String(describing: ItemCategory.self):
            let mapping: (CursorIterator) throws -> ItemCategory = { cursor in
                return try ItemCategory(cursor)
            }
            let fetching: Maybe<[ItemCategory]> =  self.fetch(from: ItemCategoriesTable.self, mapping: mapping, size: size)
            return fetching.map { $0.compactMap { $0 as? T } }
            
        case String(describing: ReadItem.self):
            let collectionMapping: (CursorIterator) throws -> ReadCollection = { cursor in
                return try ReadCollectionTable.Entity(cursor).asCollection()
            }
            let collections: Maybe<[ReadCollection]> =  self.fetch(from: ReadCollectionTable.self, mapping: collectionMapping, size: size)
            
            let thenLoadLinks: ([ReadCollection]) -> Maybe<[ReadItem]> = { [weak self] collections in
                guard let self = self else { return .empty() }
                let linkMapping: (CursorIterator) throws -> ReadLink = { cursor in
                    return try ReadLinkTable.Entity(cursor).asLinkItem()
                }
                let links: Maybe<[ReadLink]> =  self.fetch(from: ReadLinkTable.self, mapping: linkMapping, size: size)
                return links.map { collections + $0 }
            }
            return collections.flatMap(thenLoadLinks)
                .map { $0.compactMap { $0 as? T } }
            
        case String(describing: ReadLinkMemo.self):
            let mapping: (CursorIterator) throws -> ReadLinkMemo = { cursor in
                return try ReadLinkMemo(cursor)
            }
            let fetching: Maybe<[ReadLinkMemo]> =  self.fetch(from: ReadLinkMemoTable.self, mapping: mapping, size: size)
            return fetching.map { $0.compactMap { $0 as? T } }
            
        default: return .empty()
        }
    }
    
    public func remove<T>(_ type: T.Type, in ids: [String]) -> Maybe<Void> {
        
        let typeName = String(describing: type.self)
        switch typeName {
        case String(describing: ItemCategory.self):
            return self.remove(from: ItemCategoriesTable.self, idColume: .itemID, ids: ids)
            
        case String(describing: ReadItem.self):
            let removeCollections = self.remove(from: ReadCollectionTable.self, idColume: .uid, ids: ids)
            let thenRemoveLinks: () -> Maybe<Void> = { [weak self] in
                guard let self = self else { return .empty() }
                return self.remove(from: ReadLinkTable.self, idColume: .uid, ids: ids)
            }
            return removeCollections.flatMap(thenRemoveLinks)
            
        case String(describing: ReadLinkMemo.self):
            return self.remove(from: ReadLinkMemoTable.self, idColume: .itemID, ids: ids)
            
        default: return .empty()
        }
    }
    
    public func save<T>(_ type: T.Type, _ models: [T]) -> Maybe<Void> {
        
        let typeName = String(describing: type.self)
        switch typeName {
        case String(describing: ItemCategory.self):
            guard let categories = models as? [ItemCategory] else { return .empty() }
            return self.updateCategories(categories)
            
        case String(describing: ReadItem.self):
            guard let items = models as? [ReadItem] else { return .empty() }
            let collections = items.compactMap { $0 as? ReadCollection }
            let links = items.compactMap { $0 as? ReadLink }
            let updateCollections = collections.isNotEmpty
                ? self.updateReadCollections(collections)
                : .just()
            let thenUpdateLinks: () -> Maybe<Void> = { [weak self] in
                guard let self = self else { return .empty() }
                guard links.isNotEmpty else { return .just() }
                return self.updateReadLinks(links)
            }
            return updateCollections.flatMap(thenUpdateLinks)
            
        case String(describing: ReadLinkMemo.self):
            guard let memos = models as? [ReadLinkMemo] else { return .empty() }
            return self.sqliteService.rx.run { try $0.insert(ReadLinkMemoTable.self, entities: memos) }
            
        default: return .empty()
        }
    }
}


extension DataModelStorageImple {
    
    private func fetch<T: Table, M>(from table: T.Type,
                                    mapping: @escaping (CursorIterator) throws -> M,
                                    size: Int) -> Maybe<[M]> {
        
        let query = table.selectAll().limit(size)
        return self.sqliteService.rx.run { try $0.load(query, mapping: mapping) }
    }
    
    private func remove<T: Table>(from table: T.Type,
                                  idColume: T.ColumnType,
                                  ids: [String]) -> Maybe<Void> {
        
        let query = table.delete()
            .where { _ in idColume.in(ids) }
        return self.sqliteService.rx.run { try $0.delete(table, query: query) }
    }
}
