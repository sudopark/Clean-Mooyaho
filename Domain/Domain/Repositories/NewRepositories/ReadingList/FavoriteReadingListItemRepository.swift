//
//  FavoriteReadingListItemRepository.swift
//  Domain
//
//  Created by sudo.park on 2022/08/15.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation


public protocol FavoriteReadingListItemRepository: Sendable {
    
    func loadFavoriteItemIDs(for ownerID: String?) async throws -> [String]
    
    func loadFavoriteItems(for ownerID: String?) async throws -> [ReadingListItem]
    
    func toggleIsFavorite(for ownerID: String?, _ id: String, isOn: Bool) async throws
}
