//
//  ReadingListItemCategoryRepository.swift
//  Domain
//
//  Created by sudo.park on 2022/08/23.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation

import Extensions


public protocol ReadingListItemCategoryRepository: Sendable {
    
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
