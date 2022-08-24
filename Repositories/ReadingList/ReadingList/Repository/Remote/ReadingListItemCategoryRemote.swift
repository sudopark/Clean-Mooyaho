//
//  ReadingListItemCategoryRemote.swift
//  ReadingList
//
//  Created by sudo.park on 2022/08/23.
//

import Foundation

import Domain
import Extensions


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
    ) async throws -> ReadingListItemCategory
    
    func loadLatestCategories(
        for ownerID: String
    ) async throws -> [ReadingListItemCategory]
    
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
