//
//  SuggestCategory.swift
//  Domain
//
//  Created by sudo.park on 2021/10/09.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct SuggestCategory {
    
    public let ownerID: String?
    public let category: ItemCategory
    public var lastUpdated: TimeStamp
    
    public init(ownerID: String? = nil, category: ItemCategory, lastUpdated: TimeStamp) {
        self.ownerID = ownerID
        self.category = category
        self.lastUpdated = lastUpdated
    }
}


public struct SuggestCategoryCollection {
    
    public let query: String
    public let categories: [SuggestCategory]
    public let cursor: String?
    
    public init(query: String, categories: [SuggestCategory], cursor: String? = nil) {
        self.query = query
        self.categories = categories
        self.cursor = cursor
    }

    public static func empty(_ query: String = "") -> Self {
        return .init(query: query, categories: [], cursor: nil)
    }
    
    public var isEmpty: Bool {
        return self.categories.isEmpty
    }
}
