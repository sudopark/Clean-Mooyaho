//
//  ReadingListItemCategoryRemote.swift
//  ReadingList
//
//  Created by sudo.park on 2022/08/23.
//

import Foundation

import Domain
import Remote
import Extensions
import Prelude
import Optics


public protocol ReadingListItemCategoryRemote: Sendable {
    
    func loadCategories(in ids: [String]) async throws -> [ReadingListItemCategory]
    
    func loadCategories(
        for ownerID: String,
        earilerThan creatTime: TimeStamp,
        pageSize: Int
    ) async throws -> [ReadingListItemCategory]
    
    func loadCategory(
        for ownerID: String,
        by name: String
    ) async throws -> ReadingListItemCategory?
    
    func saveCategories(
        for ownerID: String,
        _ categories: [ReadingListItemCategory]
    ) async throws
    
    func updateCategory(
        for ownerID: String,
        _ category: ReadingListItemCategory
    ) async throws -> ReadingListItemCategory
    
    func removeCategory(_ uid: String) async throws
}


public final class ReadingListItemCategoryRemoteImple: ReadingListItemCategoryRemote {
    
    private let restRemote: RestRemote
    
    public init(restRemote: RestRemote) {
        self.restRemote = restRemote
    }
}

extension ReadingListItemCategoryRemoteImple {
    
    private typealias Keys = ReadingListItemCategoryMappingKey
    
    public func loadCategories(in ids: [String]) async throws -> [ReadingListItemCategory] {
        let endpoint = ReadingListEndpoints.categories
        let query = LoadQuery().where(.init(Keys.uid.rawValue, .in, ids))
        let memberCategories: [MemberItemCategory] = try await self.restRemote.requestFind(endpoint, byQuery: query)
        return memberCategories.map { $0.category }
    }
    
    public func loadCategories(
        for ownerID: String,
        earilerThan creatTime: TimeStamp,
        pageSize: Int
    ) async throws -> [ReadingListItemCategory] {
        
        let endpoint = ReadingListEndpoints.categories
        let query = LoadQuery()
            .where(.init(Keys.ownerID.rawValue, .equal, ownerID))
            .where(.init(Keys.createdAt.rawValue, .lessThan, creatTime))
            .order(.desc(Keys.createdAt.rawValue))
            |> \.limit .~ pageSize
        let memberCategories: [MemberItemCategory] = try await self.restRemote.requestFind(endpoint, byQuery: query)
        return memberCategories.map { $0.category }
    }
    
    public func loadCategory(for ownerID: String, by name: String) async throws -> ReadingListItemCategory? {
        let endpoint = ReadingListEndpoints.categories
        let query = LoadQuery()
            .where(.init(Keys.ownerID.rawValue, .equal, ownerID))
            .where(.init(Keys.name.rawValue, .equal, name))
        let memberCategories: [MemberItemCategory] = try await self.restRemote.requestFind(endpoint, byQuery: query)
        return memberCategories.first?.category
    }
}


extension ReadingListItemCategoryRemoteImple {
    
    public func saveCategories(for ownerID: String, _ categories: [ReadingListItemCategory]) async throws {
        let endpoint = ReadingListEndpoints.saveCategories
        let memberCategories = categories.map { MemberItemCategory(ownerID, $0) }
        let jsons = memberCategories.map { $0.asJson() }
        return try await self.restRemote.requestBatchSaves(endpoint, jsons)
    }
    
    public func updateCategory(
        for ownerID: String,
        _ category: ReadingListItemCategory
    ) async throws -> ReadingListItemCategory {
        
        let endpoint = ReadingListEndpoints.updateCategory
        let memberCategory = MemberItemCategory(ownerID, category)
        let json = memberCategory.asJson()
            |> key(Keys.uid.rawValue) .~ nil
        let updatedCategory: MemberItemCategory = try await self.restRemote.requestUpdate(
            endpoint, id: category.uid, to: json
        )
        return updatedCategory.category
    }
    
    public func removeCategory(_ uid: String) async throws {
        let endpoit = ReadingListEndpoints.removeCategory
        return try await self.restRemote.requestDelete(endpoit, byId: uid)
    }
}
