//
//  File.swift
//  Domain
//
//  Created by sudo.park on 2022/07/01.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation


public protocol ReadingListItemRepository {
    
    func loadItem(_ itemID: String) async throws -> ReadingListItem
    
    func loadItems(_ itemIDs: [String]) async throws -> [ReadingListItem]
    
    func updateItem(_ item: ReadingListItem) async throws -> ReadingListItem
    
    func findLinkItem(using url: String) async throws -> ReadLinkItem?
    
    func removeItem(_ itemID: String) async throws -> Void
}
