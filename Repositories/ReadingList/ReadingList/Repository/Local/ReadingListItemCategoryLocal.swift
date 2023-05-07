//
//  ReadingListItemCategoryLocal.swift
//  ReadingList
//
//  Created by sudo.park on 2022/08/23.
//

import Foundation

import Domain
import Local
import Extensions
import SQLiteService


// MARK: - ReadingListItemCategoryLocal

public protocol ReadingListItemCategoryLocal: Sendable {
    
    func loadCategories(in ids: [String]) async throws -> [ReadingListItemCategory]
    
    func loadCategories(
        earilerThan creatTime: TimeStamp,
        pageSize: Int
    ) async throws -> [ReadingListItemCategory]
    
    func findCategory(by name: String) async throws -> ReadingListItemCategory?
    
    func saveCategories(_ categories: [ReadingListItemCategory]) async throws
    
    func updateCategory(_ category: ReadingListItemCategory) async throws -> ReadingListItemCategory
    
    func removeCategory(_ uid: String) async throws
}


// MARK: - ReadingListItemCategoryLocalImple

public final class ReadingListItemCategoryLocalImple: ReadingListItemCategoryLocal, Sendable {
    
    private let storage: SQLiteStorage
    public init(storage: SQLiteStorage) {
        self.storage = storage
    }
}


extension ReadingListItemCategoryLocalImple {
    
    private typealias Categories = ReadingListItemCategoryTable
    
    public func loadCategories(in ids: [String]) async throws -> [ReadingListItemCategory] {
        let query = Categories.selectAll { $0.itemID.in(ids) }
        return try await self.storage.run { try $0.load(query) }
    }
    
    public func loadCategories(
        earilerThan creatTime: TimeStamp,
        pageSize: Int
    ) async throws -> [ReadingListItemCategory] {
        let query = Categories
            .selectAll { $0.createAt < creatTime }
            .orderBy(isAscending: false) { $0.createAt }
            .limit(pageSize)
        return try await self.storage.run { try $0.load(query) }
    }
    
    public func findCategory(by name: String) async throws -> ReadingListItemCategory? {
        let query = Categories.selectAll { $0.name == name }
        return try await self.storage.run { try $0.loadOne(query) }
    }
}


extension ReadingListItemCategoryLocalImple {

    public func saveCategories(_ categories: [ReadingListItemCategory]) async throws {
        try await self.storage.run { try $0.insert(Categories.self, entities: categories) }
    }
    
    public func updateCategory(_ category: ReadingListItemCategory) async throws ->  ReadingListItemCategory {
        let updateQuery = Categories.update {[
                $0.name == category.name,
                $0.colorCode == category.colorCode,
                $0.createAt == category.createdAt
            ]}
            .where { $0.itemID == category.uid }
        try await self.storage.run { try $0.update(Categories.self, query: updateQuery) }
        return category
    }
    
    public func removeCategory(_ uid: String) async throws {
        let deleteQuery = Categories.delete().where { $0.itemID == uid }
        try await self.storage.run { try $0.delete(Categories.self, query: deleteQuery) }
    }
}
